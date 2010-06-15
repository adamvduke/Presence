//
//  PersonListViewController.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "SettingsViewController.h"
#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController <ComposeStatusViewControllerDelegate>
{
	NSArray *usernameArray;
	
	// mutable array of people
	NSMutableArray *people;
	
	// operation queue for UI threading
	NSOperationQueue *queue;
	
	// activity indicator for animation during data access
	UIActivityIndicatorView	*spinner;
}

@property (retain) NSArray *usernameArray;
@property (retain) NSMutableArray *people;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) UIActivityIndicatorView	*spinner;

-(id)initWithStyle:(UITableViewStyle)style usernameArray:(NSArray *)usernames;

@end
