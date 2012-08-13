/*  DataAccessHelper.h
 *  Presence
 *
 *  Created by Adam Duke on 8/1/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@class User;
@class Status;

@interface DataAccessHelper : NSObject {
	@private
	NSString *databaseName;
	NSString *documentsDatabasePath;
}

/* copy the default database to the file system */
- (BOOL)createAndValidateDatabase;

/* save a user record in the database */
- (BOOL)saveOrUpdateUser:(User *)user;

/* retrieve a User's details from the database and
 * construct a user object from the results by their
 * numeric userId
 */
- (User *)userByUserId:(NSString *)user_id;

/* retrieve a user's image from the database */
- (UIImage *)imageForUserId:(NSString *)user_id;

/* Delete all information in the database */
- (void)deleteAllData;

@end