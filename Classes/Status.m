/*  Status.m
 *  Presence
 *
 *  Created by Adam Duke on 8/1/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "Status.h"
#import "User.h"

@implementation Status

@synthesize text;
@synthesize createdDate;
@synthesize user;


- (Status *)initWithTimelineEntry:(NSDictionary *)timelineEntry
{
	if(self = [super init])
	{
		self.text = [timelineEntry valueForKey:@"text"];
		self.createdDate = [timelineEntry valueForKey:@"created_at"];
		self.user = [[User alloc] initWithInfo:[timelineEntry valueForKey:@"user"]];
	}
	return self;
}

@end