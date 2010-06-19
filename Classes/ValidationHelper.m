//
//  ValidationHelper.m
//  Presence
//
//  Created by Adam Duke on 6/18/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "ValidationHelper.h"


@implementation ValidationHelper

static inline BOOL IsEmpty(id thing)
{
	return thing == nil
	|| ([thing respondsToSelector:@selector(length)]
		&& [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]
		&& [(NSArray *)thing count] == 0);
}
@end
