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

@class ADEngineBlock;
@class DataAccessHelper;

@interface FavoritesListViewController : UITableViewController <ComposeStatusViewControllerDelegate,
	                                               UIScrollViewDelegate,
	                                               IconDownloaderDelegate,
	                                               UITextViewDelegate>

@property (nonatomic, strong) ADEngineBlock *engineBlock;
@property (nonatomic, strong) DataAccessHelper *dataAccessHelper;

- (id)initWithUserIdArray:(NSMutableArray *)userIds;

@end
