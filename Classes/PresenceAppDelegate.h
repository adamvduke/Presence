/*  PresenceAppDelegate.h
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright Adam Duke 2009. All rights reserved.
 *
 */

#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import <UIKit/UIKit.h>

@class DataAccessHelper;

@interface PresenceAppDelegate : NSObject <UIApplicationDelegate, SA_OAuthTwitterControllerDelegate, SA_OAuthTwitterEngineDelegate>
{
	UIWindow *window;
	IBOutlet UITabBarController *tabBarController;

	@private
	NSMutableDictionary *openRequests;
	SA_OAuthTwitterEngine *engine;
	DataAccessHelper *dataAccessHelper;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (SA_OAuthTwitterEngine *)getEngineForDelegate:(id)engineDelegate;
- (void)deauthorizeEngines;
@end