//
//  Person.m
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 Adam Duke. All rights reserved.

#import "Person.h"
#import "ValidationHelper.h"

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

- (BOOL)isValid
{
	return !IsEmpty(self.imageUrlString) && !IsEmpty(self.screenName);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"UserID : %@, ScreenName : %@", userId, screenName];
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
