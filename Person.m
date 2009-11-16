//
//  Person.m
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Person.h"


@implementation Person

@synthesize personName;
@synthesize imageName;
@synthesize personStatus;

-(id)initWithName:(NSString *)pName imageName:(NSString *)iName status:(NSString *)pStatus{

	if (self == [super init]) {
		personName = pName;
		imageName = iName;
		personStatus = pStatus;
	}
	return self;
}
-(void)dealloc{

	[personName release];
	[imageName release];
	[personStatus release];
	[super dealloc];
}
@end
