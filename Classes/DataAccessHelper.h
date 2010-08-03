//
//  DataAccessHelper.h
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Status.h"
#import "FMDatabase.h"


@interface DataAccessHelper : NSObject {

	NSFileManager *fileManager;
	NSString *databaseName;
	NSString *documentsDatabasePath;
	NSString *documentsDirectoryPath;
	NSString *schemaVersionsPath;
	FMDatabase *database;
	
}

@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, retain) NSString *documentsDatabasePath;
@property (nonatomic, retain) NSString *documentsDirectoryPath;
@property (nonatomic, retain) NSString *schemaVersionsPath;
@property (nonatomic, retain) FMDatabase *database;

// copy the default database to the file system
- (BOOL) createAndValidateDatabase;

// save a person record in the database
- (BOOL) savePerson:(Person *)person;

// retrieve a Person's details from the database and 
// construct a person object from the results by their
// numeric userId
- (Person *)initPersonByUserId:(NSString *)userId;

// retrieve a Person's details from the database and 
// construct a person object from the results by their
// numeric userId
//- (Person *)initPersonByUsername:(NSString *)userName;

// save a status record to the database
+ (BOOL) saveStatus:(Status *)status;
@end
