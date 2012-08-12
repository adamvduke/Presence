/*  PresenceAppDelegate.h
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright Adam Duke 2009. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class DataAccessHelper;

@interface PresenceAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
	IBOutlet UITabBarController *tabBarController;

	@private
	DataAccessHelper *dataAccessHelper;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end