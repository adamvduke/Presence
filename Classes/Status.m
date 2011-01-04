/*  Status.m
 *  Presence
 *
 *  Created by Adam Duke on 8/1/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "Person.h"
#import "Status.h"

@implementation Status

@synthesize text;
@synthesize createdDate;
@synthesize creator;

- (void)dealloc
{
	[super dealloc];
	[text release];
	[createdDate release];
	[creator release];
}

- (Status *)initWithTimelineEntry:(NSDictionary *)timelineEntry
{
	if(self = [super init])
	{
		self.text = [timelineEntry valueForKey:@"text"];
		self.createdDate = [timelineEntry valueForKey:@"created_at"];
		self.creator = [[[Person alloc] initWithInfo:[timelineEntry valueForKey:@"user"]] autorelease];
	}
	return self;
}

@end