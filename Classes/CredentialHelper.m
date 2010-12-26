/*  CredentialHelper.m
 *  Presence
 *
 *  Created by Adam Duke on 6/20/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "CredentialHelper.h"
#import "PresenceConstants.h"

@interface CredentialHelper (Private)

/* convenience method to save a given string for a given key */
+ (void)saveString:(NSString *)string forKey:(NSString *)key;

/* convenience method to return a string for a given key */
+ (NSString *)retrieveStringForKey:(NSString *)key;

@end

@implementation CredentialHelper

/* saves the given username to the standard NSUserDefaults with the key "UsernameKey" */
+ (void)saveUsername:(NSString *)username
{
	[self saveString:username forKey:UsernameKey];
}

/* Returns the value saved in the standard UserDefaults for the key "UsernameKey" */
+ (NSString *)retrieveUsername
{
	return [self retrieveStringForKey:UsernameKey];
}

/* saves the given username to the standard NSUserDefaults with the key "AuthDataKey" */
+ (void)saveAuthData:(NSString *)authData
{
	[self saveString:authData forKey:AuthDataKey];
}

/* Returns the value saved in the standard UserDefaults for the key "AuthDataKey" */
+ (NSString *)retrieveAuthData
{
	return [self retrieveStringForKey:AuthDataKey];
}

/* convenience method to save a given string for a given key */
+ (void)saveString:(NSString *)string forKey:(NSString *)key
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:string forKey:key];
	[defaults synchronize];
}

/* convenience method to return a string for a given key */
+ (NSString *)retrieveStringForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)removeCredentials
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:AuthDataKey];
	[defaults removeObjectForKey:UsernameKey];
	[defaults synchronize];
}

@end