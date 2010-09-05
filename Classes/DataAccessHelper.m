//
//  DataAccessHelper.m
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "DataAccessHelper.h"
#import "FMDatabase.h"

@implementation DataAccessHelper

@synthesize fileManager;
@synthesize databaseName;
@synthesize documentsDatabasePath;
@synthesize documentsDirectoryPath;
@synthesize schemaVersionsPath;

/* Release memory that is being held in any instance variables during deconstruction
 */
- (void) dealloc
{
	[super dealloc];
	[fileManager release];
	[databaseName release];
	[documentsDatabasePath release];
	[documentsDirectoryPath release];
}

/* Override the default initalizer to set up the instance variables needed for database operations
 */
-(DataAccessHelper *)init
{
	if (self == [super init]) {
		
		// initialize the fileManager
		self.fileManager = [NSFileManager defaultManager];
		
		// Get the path to the documents directory and append the databaseName
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsPath = [documentPaths objectAtIndex:0];
		self.schemaVersionsPath = [documentsPath stringByAppendingPathComponent:@"SchemaVersions.plist"];
		self.documentsDatabasePath = [documentsPath stringByAppendingPathComponent:@"Presence.db"];
		self.documentsDirectoryPath = documentsPath;
		if (![self.fileManager fileExistsAtPath:self.schemaVersionsPath]) {
			NSString *bundleSchemaVersionsPath = [[NSBundle mainBundle]pathForResource:@"SchemaVersions" ofType:@"plist"];
			[self.fileManager copyItemAtPath:bundleSchemaVersionsPath toPath:self.schemaVersionsPath error:nil];
		}
	}
	return self;
}

/* Convenience method to get a reference to an open FMDatabase object and log any associated erros
 */
- (FMDatabase *) openApplicationDatabase
{
	FMDatabase *database = [FMDatabase databaseWithPath:self.documentsDatabasePath];
	if (![database open]) {
		NSLog(@"Error opening database.");
		if ([database hadError]) {
			NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
		}
	}
	return database;
}

/* Determines the current state of the database schema and applies the neccesary updates 
   to match the currently expected version by the application
 */
- (void) updateSchema
{
	NSMutableDictionary *schemaVersions = [NSMutableDictionary dictionaryWithContentsOfFile:self.schemaVersionsPath];
	[schemaVersions retain];
	NSInteger currentVersion = [[schemaVersions objectForKey:@"CurrentVersion"] integerValue];
	NSInteger targetVersion = [[schemaVersions objectForKey:@"TargetVersion"] integerValue];
	
	BOOL writeSchemaVersions = NO;
	while (currentVersion < targetVersion) {
		
		writeSchemaVersions = YES;
		NSString *fileName = [NSString stringWithFormat:@"Schema_Version_%d", currentVersion + 1];
		
		// get the list of statements to create the schema
		NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"plist"];
		NSArray *sqlStatements = [NSArray arrayWithContentsOfFile:path];
		
		// open the database
		FMDatabase *database = [self openApplicationDatabase];
		
		// execute the statements
		for(NSString *statement in sqlStatements)
		{
			[database executeUpdate:statement];
			if ([database hadError]) {
				NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
			}
		}
		[database close];
		
		//increment version
		currentVersion++;
		NSNumber *updatedToVersion = [NSNumber numberWithInt:currentVersion];
		[schemaVersions setValue:updatedToVersion forKey:@"CurrentVersion"];
	}
	if (writeSchemaVersions) {
		[schemaVersions writeToFile:self.schemaVersionsPath atomically:YES];
	}
	[schemaVersions release];
}

// create the default database and save it in the Documents directory
- (BOOL) createAndValidateDatabase
{
	// open the database
	FMDatabase *database = [self openApplicationDatabase];
	
	[self updateSchema];
	
	// close the database
	[database close];
	return YES;
}

// save a Person object's details to the database
- (BOOL) savePerson:(Person *)person
{
	// open the database
	FMDatabase *database = [self openApplicationDatabase];
	
	// attempt to select a record based on the username
	FMResultSet *resultSet = [database executeQuery:@"select id from Person where userId = ?", person.userId];
	
	// if the resultset contains a record this is an update
	if ([resultSet next]) 
	{
		//execute update
		[database beginTransaction];
		[database executeUpdate:@"update person set screenName = ?, imageUrlString = ?, image = ? where userId = ?", 
		 person.screenName,
		 person.imageUrlString, 
		 UIImagePNGRepresentation(person.image),
		 person.userId];
		[database commit];
	}
	
	// if the resultset does not contain an update this is an insert
	else 
	{
		//execute insert
		[database beginTransaction];
		[database executeUpdate:@"insert into Person (userId, screenName, imageUrlString, image) values (?, ?, ?, ?)", 
		 person.userId, 
		 person.screenName, 
		 person.imageUrlString, 
		 UIImagePNGRepresentation(person.image)];
		[database commit];		
	}
	
	// close the resultset and database
	[resultSet close];
	[database close];
	
	return YES;
}

/*
 Attempt to initialize and populate a Person object using data in the database for the given 
 userId
 */
- (Person *) initPersonByUserId:(NSString *)userId
{
	// open the database
	FMDatabase *database = [self openApplicationDatabase];
	
	Person *person = [[Person alloc]init];
	
	// query the database for the Person's details
	FMResultSet *resultSet = [database executeQuery:@"select * from Person where userId = ?", userId];
	
	// if the resultset contains data, construct a Person object from it
	while ([resultSet next]) {
		person.userId = userId;
		person.screenName = [resultSet stringForColumn:@"screenName"];
		person.imageUrlString = [resultSet stringForColumn:@"imageUrlString"];
		person.image = [UIImage imageWithData:[resultSet dataForColumn:@"image"]];
	}
	
	//close the resultset and database
	[resultSet close];
	[database close];
	
	// return the Person
	return person;
}

/* Attempt to retrieve an image from the database for the given userId. The image data is stored in a blob type
 */
- (UIImage *)initImageForUserId:(NSString *)userId
{
	FMDatabase *database = [self openApplicationDatabase];
	
	FMResultSet *resultSet = [database executeQuery:@"select image from Person where userId = ?", userId];
	
	UIImage *returnImage = nil;
	if([resultSet next]) {
		returnImage = [[UIImage alloc]initWithData:[resultSet dataForColumn:@"image"]];
	}
	return returnImage;
}

/* Attempt to retrieve the userId for a user given that user's screenName
 */
- (NSString *)fetchUserIdByScreenName:(NSString *)screenName
{
	// open the database
	FMDatabase *database = [self openApplicationDatabase];
	FMResultSet *resultSet = [database executeQuery:@"select userId from Person where screenName = ?", screenName];
	NSString *userId = nil;
	while ([resultSet next]) {
		userId = [resultSet stringForColumn:@"userId"];
	}
	[resultSet close];
	[database close];
	
	return userId;
}

+ (BOOL) saveStatus:(Status *)status
{
	return YES;
}
@end
