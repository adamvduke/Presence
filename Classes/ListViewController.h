//
//  PersonListViewController.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "SettingsViewController.h"
#import "IconDownloader.h"
#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController < ComposeStatusViewControllerDelegate, UIScrollViewDelegate, IconDownloaderDelegate>
{
	// the list of users to display
	NSArray *usernameArray;
	
	// mutable array of people
	NSMutableArray *people;
	
	// set of icon downloader objects
	NSMutableDictionary *imageDownloadsInProgress;
	
	// operation queue for UI threading
	NSOperationQueue *queue;
}

@property (nonatomic, retain) NSArray *usernameArray;
@property (nonatomic, retain) NSMutableArray *people;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSOperationQueue *queue;

- (id)initWithStyle:(UITableViewStyle)style usernameArray:(NSArray *)usernames;
- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end
