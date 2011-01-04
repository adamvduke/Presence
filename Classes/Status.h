/*  Status.h
 *  Presence
 *
 *  Created by Adam Duke on 8/1/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@class User;

@interface Status : NSObject
{
	NSString *text;
	NSString *createdDate;
	User *user;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *createdDate;
@property (nonatomic, retain) User *user;

- (Status *)initWithTimelineEntry:(NSDictionary *)timelineEntry;

@end