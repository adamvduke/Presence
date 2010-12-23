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
	DataAccessHelper *dataAccessHelper;

	@private
	SA_OAuthTwitterEngine *engine;
	UIBarButtonItem *addBarButton;
	UIBarButtonItem *composeBarButton;
	NSMutableArray *userIdArray;
	NSMutableArray *people;
	NSMutableDictionary *imageDownloadsInProgress;
	int finishedThreads;
}

@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;

- (id)initAsEditable:(BOOL)isEditable userIdArray:(NSArray *)userIds;

/* IconDownloader delegate protocol */
- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end