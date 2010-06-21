//
//  CredentialHelper.m
//  Presence
//
//  Created by Adam Duke on 6/20/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "CredentialHelper.h"
#import "PresenceContants.h"


@implementation CredentialHelper


+(NSString *)retrieveUsername
{
	NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:UsernameKey];
	return username;
}

+(NSString *)retrievePassword
{
	
	NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:PasswordKey];
	return password;
}

@end
