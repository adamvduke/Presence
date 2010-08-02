//
//  DataAccessHelper.m
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "DataAccessHelper.h"

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
- (void) initializeFileManager
{
	if (self.fileManager == nil) {
		self.fileManager = [NSFileManager defaultManager];
	}
}

- (BOOL) createAndValidateDatabase
{	
	[self initializeFileManager];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [documentPaths objectAtIndex:0];
	self.documentsDatabasePath = [documentsPath stringByAppendingPathComponent:@"Presence.db"];
	
	// check to see if the database exists
	if([self.fileManager fileExistsAtPath:self.documentsDatabasePath])
	{
		return YES;
	}
	
	// if not, copy the default database to the documents directory
	[self copyDatabaseToPath:self.documentsDatabasePath];
	
	return [self.fileManager fileExistsAtPath:self.documentsDatabasePath];
}

- (void) copyDatabaseToPath:(NSString *)toPath
{
	[self initializeFileManager];
	
	// get the default database from the app bundle and copy it to the documents directory
	NSString *path = [[NSBundle mainBundle]pathForResource:@"Presence" ofType:@"db"];
	NSError *error;
	[self.fileManager copyItemAtPath:path toPath:self.documentsDatabasePath error:&error];
	if (error != nil) {
		NSLog(@"Error copying database, %@", [error description]);
	}
}

+ (BOOL) savePerson:(Person *)person
{
	
	return YES;
}

+ (BOOL) saveStatus:(Status *)status
{
	
	return YES;
}
@end
