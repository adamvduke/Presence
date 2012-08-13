/*  FollowingListViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 8/13/12.
 *  Copyright (c) 2012 Adam Duke. All rights reserved.
 *
 */

#import "ComposeStatusViewController.h"
#import "IconDownloader.h"
#import <UIKit/UIKit.h>

@class ADEngineBlock;
@class DataAccessHelper;

@interface FollowingListViewController : UITableViewController <ComposeStatusViewControllerDelegate, UIScrollViewDelegate, IconDownloaderDelegate, UITextViewDelegate>

@property (nonatomic, strong) ADEngineBlock *engineBlock;
@property (nonatomic, strong) DataAccessHelper *dataAccessHelper;
@property (nonatomic, strong) NSMutableArray *userIdArray;
@property (nonatomic, strong) UIBarButtonItem *composeBarButton;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property int finishedThreads;

- (id)initWithUserIdArray:(NSMutableArray *)userIds;
- (void)startIconDownload:(User *)aUser forIndexPath:(NSIndexPath *)indexPath;
- (void)startDataLoad;
- (void)startUserLoad:(NSString *)user_id;
- (void)infoRecievedForUser:(User *)user;
- (void)didFinishLoadingUser;

/* IconDownloader delegate protocol */
- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end
