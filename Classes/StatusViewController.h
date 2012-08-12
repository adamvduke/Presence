/*  StatusViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 11/17/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class DataAccessHelper;
@class User;

@interface StatusViewController : UITableViewController
{
	@private
	UIActivityIndicatorView *spinner;
	User *user;
	DataAccessHelper *dataAccessHelper;
}

/* initialize an instance with a UITableViewStyle and User object */
- (id)initWithUser:(User *)aUser dataAccessHelper:(DataAccessHelper *)accessHelper;

@end