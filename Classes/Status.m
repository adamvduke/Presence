//
//  Status.m
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "Status.h"


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
@end
