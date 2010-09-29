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
	
	// label to identify the live data switch
	IBOutlet UILabel *liveDataLabel;
		
	// switch to select between live twitter data and test data
	IBOutlet UISwitch *liveDataSwitch;
}

@property (nonatomic, retain)UINavigationItem *aNavigationItem;
@property (nonatomic, retain)UILabel *liveDataLabel;
@property (nonatomic, retain)UISwitch *liveDataSwitch;

// Provide an implementation to save the user's settings
- (IBAction)save;
@end