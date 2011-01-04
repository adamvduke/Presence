/*  Person.m
 *  Presence
 *
 *  Created by Adam Duke on 11/12/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 */

#import "Person.h"
#import "ValidationHelper.h"

@implementation Person

@synthesize user_id, screen_name, display_name, display_location, display_description, display_url, profile_image_url, statusUpdates, image;

/* Returns a Person object initialized with an NSDictionary of information retrieved
 * using the TwitterHelper, for a particular user name
 */
- (Person *)initPersonWithInfo:(NSDictionary *)userInfo
{
	if(self = [super init])
	{
		/* get the values out of the userInfo dictionary */
		self.user_id = [userInfo valueForKey:@"id_str"];
		self.screen_name = [userInfo valueForKey:@"screen_name"];
		self.display_name = [userInfo valueForKey:@"name"];
		self.display_location = [userInfo valueForKey:@"location"];
		self.display_description = [userInfo valueForKey:@"description"];
		self.display_url = [userInfo valueForKey:@"url"];
		self.profile_image_url = [userInfo valueForKey:@"profile_image_url"];
	}
	return self;
}

- (BOOL)isValid
{
	return !IsEmpty(self.user_id) && !IsEmpty(self.screen_name);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"UserID : %@, ScreenName : %@", user_id, screen_name];
}

- (void)dealloc
{
	[user_id release];
	[screen_name release];
	[display_name release];
	[display_location release];
	[display_description release];
	[display_url release];
	[profile_image_url release];
	[statusUpdates release];
	[image release];
	[super dealloc];
}

@end