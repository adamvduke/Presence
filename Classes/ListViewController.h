/*  ListViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "ComposeStatusViewController.h"
#import "IconDownloader.h"
#import <UIKit/UIKit.h>

@class DataAccessHelper;
@class User;

@interface ListViewController : UITableViewController <ComposeStatusViewControllerDelegate,
	                                               UIScrollViewDelegate,
	                                               IconDownloaderDelegate,
	                                               UITextViewDelegate>
{
	DataAccessHelper *dataAccessHelper;
	NSMutableArray *userIdArray;

	@protected
	UIBarButtonItem *composeBarButton;
	NSMutableArray *users;
	NSMutableDictionary *imageDownloadsInProgress;
	int finishedThreads;
}

@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;
@property (nonatomic, retain) UIBarButtonItem *composeBarButton;
@property (nonatomic, retain) NSMutableArray *userIdArray;
@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property int finishedThreads;

- (id)initWithUserIdArray:(NSMutableArray *)userIds;
- (void)synchronousLoadUser:(NSString *)user_id;
- (void)infoRecievedForUser:(User *)user;
- (void)didFinishLoadingUser;
- (void)synchronousLoadTwitterData;

/* IconDownloader delegate protocol */
- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end