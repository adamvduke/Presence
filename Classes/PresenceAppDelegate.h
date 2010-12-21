/*  PresenceAppDelegate.h
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright Adam Duke 2009. All rights reserved.
 *
 */

#import "DataAccessHelper.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import <UIKit/UIKit.h>

@interface PresenceAppDelegate : NSObject <UIApplicationDelegate, SA_OAuthTwitterControllerDelegate, SA_OAuthTwitterEngineDelegate>
{
	UIWindow *window;
	IBOutlet UITabBarController *tabBarController;

	/* Treated as a singleton */
	DataAccessHelper *dataAccessHelper;

	SA_OAuthTwitterEngine *engine;
	NSMutableDictionary *openRequests;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;
@property (nonatomic, retain) NSMutableDictionary *openRequests;

- (SA_OAuthTwitterEngine *)getEngineForDelegate:(id)engineDelegate;
@end