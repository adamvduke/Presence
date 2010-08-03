//
//  Person.m
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import "Person.h"

@implementation Person

@synthesize userId;
@synthesize screenName;
@synthesize imageUrlString;
@synthesize statusUpdates;
@synthesize image;

// Returns a Person object initialized with an NSDictionary of information retrieved 
// using the TwitterHelper, for a particular user name
- (Person *) initPersonWithInfo:(NSDictionary *)userInfo 
{	
	if (self == [super init]) 
	{
		//get the values out of the userInfo dictionary
		NSNumber *rawId = [userInfo valueForKey:@"id"];
		self.userId = [NSString stringWithFormat:@"%d",[rawId integerValue]];
		self.imageUrlString = [userInfo valueForKey:@"profile_image_url"];
		self.screenName = [userInfo valueForKey:@"screen_name"];		
	}
	return self;
}

+ (BOOL)isValid:(Person *)person
{
	return (person.imageUrlString != nil && [person.imageUrlString length] > 0) && (person.screenName != nil && [person.screenName length] > 0);
}

- (void)dealloc
{
	[userId release];
	[screenName release];
	[imageUrlString release];
	[statusUpdates release];
	[image release];
	[super dealloc];
}
@end
