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

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *createdDate;
@property (nonatomic, strong) User *user;

- (Status *)initWithTimelineEntry:(NSDictionary *)timelineEntry;

@end