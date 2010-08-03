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
- (Person *) initPersonWithInfo:(NSDictionary *)userInfo userId:(NSString *)aUserId 
{	
	if (self == [super init]) 
	{
		//get the values out of the userInfo dictionary for the url string and display name
		NSString *theImageUrlString = [userInfo valueForKey:@"profile_image_url"];
		NSString *theScreenName = [userInfo valueForKey:@"screen_name"];
		
		self.userId = aUserId;
		self.screenName = theScreenName;
		self.imageUrlString = theImageUrlString;
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
