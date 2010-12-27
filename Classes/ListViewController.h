/*  PersonListViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "ComposeStatusViewController.h"
#import "IconDownloader.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "SettingsViewController.h"
#import <UIKit/UIKit.h>

@class DataAccessHelper;

@interface ListViewController : UITableViewController <ComposeStatusViewControllerDelegate,
	                                               UIScrollViewDelegate,
	                                               IconDownloaderDelegate,
	                                               UITextViewDelegate,
	                                               SA_OAuthTwitterEngineDelegate>
{
	DataAccessHelper *dataAccessHelper;
	NSMutableArray *userIdArray;

	@protected
	SA_OAuthTwitterEngine *engine;
	UIBarButtonItem *composeBarButton;
	NSMutableArray *people;
	NSMutableDictionary *imageDownloadsInProgress;
	int finishedThreads;
}

@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;
@property (nonatomic, retain) UIBarButtonItem *composeBarButton;
@property (nonatomic, retain) SA_OAuthTwitterEngine *engine;
@property (nonatomic, retain) NSMutableArray *userIdArray;
@property (nonatomic, retain) NSMutableArray *people;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property int finishedThreads;

- (id)initWithUserIdArray:(NSMutableArray *)userIds;
- (void)synchronousLoadPerson:(NSString *)user_id;
- (void)infoRecievedForPerson:(Person *)person;
- (void)didFinishLoadingPerson;
- (void)synchronousLoadTwitterData;

/* IconDownloader delegate protocol */
- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end