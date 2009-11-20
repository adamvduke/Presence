//
//  Person.m
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Person.h"


@implementation Person

@synthesize userName;
@synthesize displayName;
@synthesize imageUrlString;
@synthesize statusUpdates;
@synthesize image;

-(void)dealloc{

	[userName release];
	[displayName release];
	[imageUrlString release];
	[statusUpdates release];
	[image release];
	[super dealloc];
}
@end
