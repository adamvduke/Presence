/*  PersonListViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "ComposeStatusViewController.h"
#import "DataAccessHelper.h"
#import "IconDownloader.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "SettingsViewController.h"
#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController <ComposeStatusViewControllerDelegate,
	                                               UIScrollViewDelegate,
	                                               IconDownloaderDelegate,
	                                               UITextViewDelegate,
	                                               SA_OAuthTwitterEngineDelegate>
{
	SA_OAuthTwitterEngine *engine;
	NSMutableDictionary *openRequests;

	UIBarButtonItem *addBarButton;
	UIBarButtonItem *composeBarButton;

	/* the list of users to display */
	NSMutableArray *userIdArray;

	/* mutable array of people */
	NSMutableArray *people;

	/* set of icon downloader objects */
	NSMutableDictionary *imageDownloadsInProgress;

	/* count of the number of threads that are finished loading data */
	int finishedThreads;

	DataAccessHelper *dataAccessHelper;
}

@property (nonatomic, retain) NSMutableDictionary *openRequests;
@property (nonatomic, retain) UIBarButtonItem *addBarButton;
@property (nonatomic, retain) UIBarButtonItem *composeBarButton;
@property (nonatomic, retain) NSMutableArray *userIdArray;
@property (nonatomic, retain) NSMutableArray *people;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;
@property int finishedThreads;

- (id)initAsEditable:(BOOL)isEditable userIdArray:(NSArray *)userIds;

/* IconDownloader delegate protocol */
- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end