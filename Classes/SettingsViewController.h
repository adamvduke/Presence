/*  SettingsViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 6/3/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class DataAccessHelper;

@interface SettingsViewController : UIViewController
{
	/* navigation item */
	IBOutlet UINavigationItem *aNavigationItem;
	IBOutlet UIButton *deauthorizeButton;

	/* Data access helper */
	DataAccessHelper *dataAccessHelper;
}

@property (nonatomic, strong) UINavigationItem *aNavigationItem;
@property (nonatomic, strong) UIButton *deauthorizeButton;
@property (nonatomic, strong) DataAccessHelper *dataAccessHelper;

/* Provide an implementation to remove the user's saved authorization credentials */
- (IBAction)deauthorize;

/* Provide an implementation to delete any saved data */
- (IBAction)deleteData;

@end