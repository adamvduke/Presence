//
//  Person.m
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import "Person.h"

@implementation Person

@synthesize userName;
@synthesize displayName;
@synthesize imageUrlString;
@synthesize statusUpdates;
@synthesize image;

// Returns a Person object initialized with an NSDictionary of information retrieved 
// using the TwitterHelper, for a particular user name
- (Person *) initPersonWithInfo:(NSDictionary *)userInfo userName:(NSString *)theUserName 
{	
	if (self == [super init]) 
	{
		//Keys in the dictionary for the url string and display name
		NSString *theImageUrlString = [userInfo valueForKey:@"profile_image_url"];
		NSString *theDisplayName = [userInfo valueForKey:@"screen_name"];
		
		if (theImageUrlString == nil || theDisplayName == nil) {
			return nil;
		}
		
		self.userName = theUserName;
		self.displayName = theDisplayName;
		self.imageUrlString = theImageUrlString;
	}
	return self;
}

- (void)dealloc
{
	[userName release];
	[displayName release];
	[imageUrlString release];
	[statusUpdates release];
	[image release];
	[super dealloc];
}
@end
