/*  StatusViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 11/17/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class ADEngineBlock;
@class DataAccessHelper;
@class User;

@interface StatusViewController : UITableViewController

@property (nonatomic, strong) ADEngineBlock *engineBlock;

/* initialize an instance with a UITableViewStyle and User object */
- (id)initWithUser:(User *)aUser dataAccessHelper:(DataAccessHelper *)accessHelper engine:(ADEngineBlock *)engine;

@end