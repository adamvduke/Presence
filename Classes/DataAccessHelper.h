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


@interface DataAccessHelper : NSObject {

	NSFileManager *fileManager;
	NSString *databaseName;
	NSString *documentsDatabasePath;
}

@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, retain) NSString *documentsDatabasePath;

- (BOOL) createAndValidateDatabase;

+ (BOOL) savePerson:(Person *)person;

+ (BOOL) saveStatus:(Status *)status;
@end
