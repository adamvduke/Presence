//
//  Status.m
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "Status.h"

@interface Status (Private)

-(NSString *)retrieveCreaterIdFromDictionary:(NSDictionary *)dictionary;

@end

@implementation Status

@synthesize text;
@synthesize createdDate;
@synthesize createrId;

- (void)dealloc
{
	[super dealloc];
	[text release];
	[createdDate release];
	[createrId release];
}

- (Status *)initWithTimelineEntry:(NSDictionary *)timelineEntry
{
	if (self == [super init]) {
		self.text = [timelineEntry valueForKey:@"text"];
		self.createdDate = [timelineEntry valueForKey:@"created_at"];
		self.createrId = [self retrieveCreaterIdFromDictionary:[timelineEntry valueForKey:@"user"]];
	}
	return self;
}

- (NSString *)retrieveCreaterIdFromDictionary:(NSDictionary *)dictionary
{
	NSNumber *rawId = [dictionary valueForKey:@"id"];
	NSString *stringId = [NSString stringWithFormat:@"%d",[rawId integerValue]];
	return stringId;
}
@end