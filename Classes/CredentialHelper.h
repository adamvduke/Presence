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

// Returns the value saved in the standard UserDefaults for the key "UsernameKey"
+ (NSString *)retrieveScreenName;

// Returns the value saved in the standard UserDefaults for the key "PasswordKey"
+ (NSString *)retrievePassword;

@end