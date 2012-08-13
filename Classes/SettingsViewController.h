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

@property (nonatomic, strong) IBOutlet UINavigationItem *aNavigationItem;
@property (nonatomic, strong) IBOutlet UIButton *deauthorizeButton;
@property (nonatomic, strong) DataAccessHelper *dataAccessHelper;

/* Provide an implementation to remove the user's saved authorization credentials */
- (IBAction)deauthorize;

/* Provide an implementation to delete any saved data */
- (IBAction)deleteData;

@end