//
//  SettingsViewController.h
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController 
{
	// label to identify the username field
	IBOutlet UILabel *usernameLabel;
	
	// label to identify the password field
	IBOutlet UILabel *passwordLabel;
	
	// text field for the username
	IBOutlet UITextField *usernameField;
	
	// text field for the password
	IBOutlet UITextField *passwordField;
	
	// switch to select between live twitter data and test data
	IBOutlet UISwitch *liveDataSwitch;
	
	// the settings view controller delegate
	id<SettingsViewControllerDelegate> delegate;
}

@property (retain)UILabel *usernameLabel;
@property (retain)UILabel *passwordLabel;
@property (retain)UITextField *usernameField;
@property (retain)UITextField *passwordField;
@property (retain)UISwitch *liveDataSwitch;
@property (assign) id<SettingsViewControllerDelegate> delegate;

// Provide an implementation to dismiss this view contoller when presented modally
-(IBAction)dismiss;

// Provide an implementation to save the user's settings
-(IBAction)save;
@end


@protocol SettingsViewControllerDelegate<NSObject>

-(void)didFinish:(SettingsViewController *)viewController;

@end
