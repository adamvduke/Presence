//
//  CredentialHelper.h
//  Presence
//
//  Created by Adam Duke on 6/20/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CredentialHelper : NSObject {

}

// Saves the value of the given username
+ (void)saveUsername:(NSString *)username;

// Returns the saved username
+ (NSString *)retrieveUsername;

// Saves the value of the given authData
+ (void)saveAuthData:(NSString *)authData;

// Returns the saved authData
+ (NSString *)retrieveAuthData;

+ (void)removeCredentials;

@end