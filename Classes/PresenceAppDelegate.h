//
//  PresenceAppDelegate.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresenceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

