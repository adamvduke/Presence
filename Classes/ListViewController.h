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
#import "DataAccessHelper.h"

#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController <ComposeStatusViewControllerDelegate, UIScrollViewDelegate, IconDownloaderDelegate, UITextViewDelegate>
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
	
	// count of the number of threads that are finished loading data
	int finishedThreads;
	
	DataAccessHelper *dataAccessHelper;
}

@property (nonatomic, retain) UIBarButtonItem *addBarButton;
@property (nonatomic, retain) UIBarButtonItem *composeBarButton;
@property (nonatomic, retain) NSMutableArray *usernameArray;
@property (nonatomic, retain) NSMutableArray *people;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;
@property int finishedThreads;

- (id)initAsEditable:(BOOL)isEditable usernameArray:(NSArray *)usernames dataAccessHelper:(DataAccessHelper *)accessHelper;
- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end
