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

- (void) updateSchema
{
	NSMutableDictionary *schemaVersions = [NSMutableDictionary dictionaryWithContentsOfFile:self.schemaVersionsPath];
	[schemaVersions retain];
	NSInteger currentVersion = [[schemaVersions objectForKey:@"CurrentVersion"] integerValue];
	NSInteger targetVersion = [[schemaVersions objectForKey:@"TargetVersion"] integerValue];
	
	while (currentVersion < targetVersion) {
		
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
	[schemaVersions writeToFile:self.schemaVersionsPath atomically:YES];
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
	FMResultSet *resultSet = [database executeQuery:@"select id from Person where userName = ?", person.userName];
	
	// if the resultset contains a record this is an update
	if ([resultSet next]) 
	{
		//execute update
		[database beginTransaction];
		[database executeUpdate:@"update person set displayName = ?, imageUrlString = ?, image = ? where userName = ?", 
		 person.displayName,
		 person.imageUrlString, 
		 UIImagePNGRepresentation(person.image),
		 person.userName];
		[database commit];
	}
	
	// if the resultset does not contain an update this is an insert
	else 
	{
		//execute insert
		[database beginTransaction];
		[database executeUpdate:@"insert into Person (userName, displayName, imageUrlString, image) values (?, ?, ?, ?)", 
		 person.userName, 
		 person.displayName, 
		 person.imageUrlString, 
		 UIImagePNGRepresentation(person.image)];
		[database commit];		
	}
	
	// close the resultset and database
	[resultSet close];
	[database close];
	
	return YES;
}

- (Person *) initPersonByUsername:(NSString *)userName
{
	// open the database
	FMDatabase *database = [self openApplicationDatabase];
	
	Person *person = [[Person alloc]init];
	
	// query the database for the Person's details
	FMResultSet *resultSet = [database executeQuery:@"select * from Person where userName = ?", userName];
	
	// if the resultset contains data, construct a Person object from it
	while ([resultSet next]) {
		person.userName = userName;
		person.displayName = [resultSet stringForColumn:@"displayName"];
		person.imageUrlString = [resultSet stringForColumn:@"imageUrlString"];
		person.image = [UIImage imageWithData:[resultSet dataForColumn:@"image"]];
	}
	
	//close the resultset and database
	[resultSet close];
	[database close];
	
	// return the Person
	return person;
}

+ (BOOL) saveStatus:(Status *)status
{
	return YES;
}
@end
