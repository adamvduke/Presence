/*  StatusViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 11/17/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "DataAccessHelper.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import <UIKit/UIKit.h>

@class Person;

@interface StatusViewController : UITableViewController <SA_OAuthTwitterEngineDelegate>
{
	@private
	UIActivityIndicatorView *spinner;
	SA_OAuthTwitterEngine *engine;
	Person *person;
	DataAccessHelper *dataAccessHelper;
}

/* initialize an instance with a UITableViewStyle and Person object */
- (id)initWithPerson:(Person *)aPerson dataAccessHelper:(DataAccessHelper *)accessHelper;

@end