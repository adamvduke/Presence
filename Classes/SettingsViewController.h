//
//  SettingsViewController.h
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController 
{
	// navigation item
	IBOutlet UINavigationItem *aNavigationItem;
	IBOutlet UIButton *deauthorizeButton;
}

@property (nonatomic, retain)UINavigationItem *aNavigationItem;
@property (nonatomic, retain)UIButton *deauthorizeButton;

// Provide an implementation to save the user's settings
- (IBAction)save;

// Provide an implementation to remove the user's saved authorization credentials
- (IBAction)deauthorize;
@end