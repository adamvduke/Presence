//
//  DataAccessHelper.m
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "DataAccessHelper.h"

@implementation DataAccessHelper

@synthesize fileManager;
@synthesize databaseName;
@synthesize documentsDatabasePath;
@synthesize documentsDirectoryPath;
@synthesize schemaVersionsPath;
@synthesize database;

- (void) dealloc
{
	[super dealloc];
	[fileManager release];
	[databaseName release];
	[documentsDatabasePath release];
	[documentsDirectoryPath release];
}

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

- (void) openApplicationDatabase
{
	if (!database) {
		self.database = [FMDatabase databaseWithPath:self.documentsDatabasePath];
	}
	if (![self.database open]) {
		NSLog(@"Error opening database.");
		if ([self.database hadError]) {
			NSLog(@"Err %d: %@", [self.database lastErrorCode], [self.database lastErrorMessage]);
		}
	}
}

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
		[self openApplicationDatabase];
		
		// execute the statements
		for(NSString *statement in sqlStatements)
		{
			[self.database executeUpdate:statement];
			if ([self.database hadError]) {
				NSLog(@"Err %d: %@", [self.database lastErrorCode], [self.database lastErrorMessage]);
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
	[self openApplicationDatabase];
	
	[self updateSchema];
	
	// close the database
	[self.database close];
	return YES;
}

// save a Person object's details to the database
- (BOOL) savePerson:(Person *)person
{
	// open the database
	[self openApplicationDatabase];
	
	// attempt to select a record based on the username
	FMResultSet *resultSet = [self.database executeQuery:@"select id from Person where userId = ?", person.userId];
	
	// if the resultset contains a record this is an update
	if ([resultSet next]) 
	{
		//execute update
		[self.database beginTransaction];
		[self.database executeUpdate:@"update person set screenName = ?, imageUrlString = ?, image = ? where userId = ?", 
		 person.screenName,
		 person.imageUrlString, 
		 UIImagePNGRepresentation(person.image),
		 person.userId];
		[self.database commit];
	}
	
	// if the resultset does not contain an update this is an insert
	else 
	{
		//execute insert
		[self.database beginTransaction];
		[self.database executeUpdate:@"insert into Person (userId, screenName, imageUrlString, image) values (?, ?, ?, ?)", 
		 person.userId, 
		 person.screenName, 
		 person.imageUrlString, 
		 UIImagePNGRepresentation(person.image)];
		[self.database commit];		
	}
	
	// close the resultset and database
	[resultSet close];
	[self.database close];
	
	return YES;
}

- (Person *) initPersonByUserId:(NSString *)userId
{
	// open the database
	[self openApplicationDatabase];
	
	Person *person = [[Person alloc]init];
	
	// query the database for the Person's details
	FMResultSet *resultSet = [self.database executeQuery:@"select * from Person where userId = ?", userId];
	
	// if the resultset contains data, construct a Person object from it
	while ([resultSet next]) {
		person.userId = userId;
		person.screenName = [resultSet stringForColumn:@"screenName"];
		person.imageUrlString = [resultSet stringForColumn:@"imageUrlString"];
		person.image = [UIImage imageWithData:[resultSet dataForColumn:@"image"]];
	}
	
	//close the resultset and database
	[resultSet close];
	[self.database close];
	
	// return the Person
	return person;
}

- (NSString *)fetchUserIdByScreenName:(NSString *)screenName
{
	// open the database
	[self openApplicationDatabase];
	FMResultSet *resultSet = [self.database executeQuery:@"select userId from Person where screenName = ?", screenName];
	NSString *userId = nil;
	while ([resultSet next]) {
		userId = [resultSet stringForColumn:@"userId"];
	}
	[resultSet close];
	[self.database close];
	
	return userId;
}

+ (BOOL) saveStatus:(Status *)status
{
	return YES;
}
@end
