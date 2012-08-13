/*  PresenceAppDelegate.h
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright Adam Duke 2009. All rights reserved.
 *
 */

#import "ADTwitterOOBViewController.h"
#import <UIKit/UIKit.h>

@class ADEngineBlock;

@interface PresenceAppDelegate : NSObject <UIApplicationDelegate, ADOAuthOOBViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) ADEngineBlock *engineBlock;

@end