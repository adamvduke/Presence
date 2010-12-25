/*  EditableListViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 12/23/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "ListViewController.h"
#import <UIKit/UIKit.h>

@interface EditableListViewController : ListViewController {
	@private
	UIBarButtonItem *addBarButton;
	NSMutableArray *pendingFavorites;
}

@end
