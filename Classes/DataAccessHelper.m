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

- (void) dealloc
{
	[super dealloc];
	[fileManager release];
	[databaseName release];
	[documentsDatabasePath release];
}

-(DataAccessHelper *)init
{
	if (self == [super init]) {
		
		// initialize the fileManager
		self.fileManager = [NSFileManager defaultManager];
		
		// Get the path to the documents directory and append the databaseName
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsPath = [documentPaths objectAtIndex:0];
		self.documentsDatabasePath = [documentsPath stringByAppendingPathComponent:@"Presence.db"];
	}
	return self;
}

// create the default database and save it in the Documents directory
- (BOOL) createAndValidateDatabase
{
	// open the database
	FMDatabase *database = [FMDatabase databaseWithPath:self.documentsDatabasePath];
	if (![database open]) {
        NSLog(@"Could not open db.");
    }
	
	// get the list of statements to create the schema
	NSString *path = [[NSBundle mainBundle]pathForResource:@"Schema_Version_1" ofType:@"plist"];
	NSArray *sqlStatements = [NSArray arrayWithContentsOfFile:path];
	
	// execute the statements
	for(NSString *statement in sqlStatements)
	{
		[database executeUpdate:statement];
		if ([database hadError]) {
			NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
		}
	}
	
	// close the database
	[database close];
	return YES;
}

// save a Person object's details to the database
- (BOOL) savePerson:(Person *)person
{
	// open the database
	FMDatabase *database = [FMDatabase databaseWithPath:self.documentsDatabasePath];
	
	// ensure the database opened successfully
	// if not, log the error and return NO
	if (![database open]) {
		NSLog(@"Error opening database.");
		return NO;
	}
	
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
	FMDatabase *database = [FMDatabase databaseWithPath:self.documentsDatabasePath];
	
	// ensure the database opened successfully
	// if not, log the error and return nil
	if (![database open]) {
		NSLog(@"Error opening database.");
		return nil;
	}
	
	Person *person = nil;
	
	// query the database for the Person's details
	FMResultSet *resultSet = [database executeQuery:@"select * from Person where userName = ?", userName];
	
	// if the resultset contains data, construct a Person object from it
	while ([resultSet next]) {
		person = [[Person alloc]init];
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
