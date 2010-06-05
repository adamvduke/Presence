//
//  ErrorHelper.m
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ErrorHelper.h"


@implementation ErrorHelper

+(void)displayErrorWithTitle:(NSString *)title Message:(NSString *)message CloseButtonTitle:(NSString *)closeButtonTitle
{
	//Display an error message
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:closeButtonTitle otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
