//
//  PersonListViewController.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "IconDownloader.h"
#import "SettingsViewController.h"

#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController <ComposeStatusViewControllerDelegate, UIScrollViewDelegate, IconDownloaderDelegate, UITextFieldDelegate>
{
	UIBarButtonItem *addBarButton;
	UIBarButtonItem *composeBarButton;

	// the list of users to display
	NSMutableArray *usernameArray;
	
	// mutable array of people
	NSMutableArray *people;
	
	// set of icon downloader objects
	NSMutableDictionary *imageDownloadsInProgress;
	
	// operation queue for UI threading
	NSOperationQueue *queue;
}

@property (nonatomic, retain) UIBarButtonItem *addBarButton;
@property (nonatomic, retain) UIBarButtonItem *composeBarButton;
@property (nonatomic, retain) NSMutableArray *usernameArray;
@property (nonatomic, retain) NSMutableArray *people;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSOperationQueue *queue;

- (id)initWithStyle:(UITableViewStyle)style editable:(BOOL)isEditable usernameArray:(NSArray *)usernames;
- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end
