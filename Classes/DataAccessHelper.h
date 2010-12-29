/*  DataAccessHelper.h
 *  Presence
 *
 *  Created by Adam Duke on 8/1/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@class Person;
@class Status;

@interface DataAccessHelper : NSObject {
	@private
	NSString *databaseName;
	NSString *documentsDatabasePath;
}

/* copy the default database to the file system */
- (BOOL)createAndValidateDatabase;

/* save a person record in the database */
- (BOOL)saveOrUpdatePerson:(Person *)person;

/* retrieve a Person's details from the database and
 * construct a person object from the results by their
 * numeric userId
 */
- (Person *)initPersonByUserId:(NSString *)user_id;

/* retrieve a Person's image from the database */
- (UIImage *)initImageForUserId:(NSString *)user_id;

/* Delete all information in the database */
- (void)deleteAllData;

@end