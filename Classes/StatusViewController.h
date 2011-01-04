/*  StatusViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 11/17/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "SA_OAuthTwitterEngine.h"
#import <UIKit/UIKit.h>

@class DataAccessHelper;
@class User;

@interface StatusViewController : UITableViewController <SA_OAuthTwitterEngineDelegate>
{
	@private
	UIActivityIndicatorView *spinner;
	SA_OAuthTwitterEngine *engine;
	User *user;
	DataAccessHelper *dataAccessHelper;
}

/* initialize an instance with a UITableViewStyle and User object */
- (id)initWithUser:(User *)aUser dataAccessHelper:(DataAccessHelper *)accessHelper;

@end