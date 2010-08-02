//
//  PresenceAppDelegate.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataAccessHelper.h"

@interface PresenceAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	DataAccessHelper *dataAccessHelper;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;

@end

