//
//  DataAccessHelper.m
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "DataAccessHelper.h"
#import "FMDatabase.h"

@interface DataAccessHelper ()

- (void)initializeFileManager;
- (void)copyDatabaseToPath:(NSString *)toPath;

@end

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

// initialize the NSFileManager object
- (void) initializeFileManager
{
	// if the NSFileManager is nil, initialize it
	if (self.fileManager == nil) {
		self.fileManager = [NSFileManager defaultManager];
	}
}

// copy the default database from the app bundle to the Document's directory
- (BOOL) createAndValidateDatabase
{		
	// ensure the NSFileManager object has been initialized
	[self initializeFileManager];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [documentPaths objectAtIndex:0];
	self.documentsDatabasePath = [documentsPath stringByAppendingPathComponent:@"Presence.db"];
	
	// check to see if the database exists
	// if so, return YES
	if([self.fileManager fileExistsAtPath:self.documentsDatabasePath])
	{
		return YES;
	}
	
	// if not, copy the default database to the documents directory
	[self copyDatabaseToPath:self.documentsDatabasePath];
	
	// return the value of fileExistsAtPath after copying
	return [self.fileManager fileExistsAtPath:self.documentsDatabasePath];
}

// copy the database from the application bundle to the Documents directory
- (void) copyDatabaseToPath:(NSString *)toPath
{
	// ensure the NSFileManager object is initialized
	[self initializeFileManager];
	
	// get the default database from the app bundle and copy it to the documents directory
	NSString *path = [[NSBundle mainBundle]pathForResource:@"Presence" ofType:@"db"];
	NSError *error = nil;
	[self.fileManager copyItemAtPath:path toPath:self.documentsDatabasePath error:&error];
	
	// log any error that may have been created during the file copy
	if (error != nil) {
		NSLog(@"Error copying database, %@", [error description]);
	}
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
