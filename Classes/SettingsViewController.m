//
//  SettingsViewController.m
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "PresenceContants.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize aNavigationItem;
@synthesize liveDataLabel;
@synthesize liveDataSwitch;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// return YES for all interface orientations
	return YES;
}

// convenience method to hide the keyboard
- (void)hideKeyBoardForTextField:(UITextField *)textField
{
	if ([textField isFirstResponder]) {
		[textField resignFirstResponder];
	}
}

// save the state of the settings to NSUserDefaults
-(IBAction)save
{	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:liveDataSwitch.isOn forKey:LiveDataKey];
	[defaults synchronize];
	
	// display an alert indicating the values were saved
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(SuccessTitleKey, @"") 
													message:NSLocalizedString(CredentialsSavedMessageKey, @"") 
												   delegate:nil cancelButtonTitle:NSLocalizedString(DismissKey, @"") otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// set the views title
	self.aNavigationItem.title = NSLocalizedString(SettingsViewTitleKey, @"");
	
	// localize the labels on the screen
	self.liveDataLabel.text = NSLocalizedString(LiveDataLabelKey, @"");
	
	// get any values out of NSUserDefaults and set those values on the fields
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.liveDataSwitch.on = [defaults boolForKey:LiveDataKey];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
}

- (void)dealloc 
{
	[liveDataSwitch release];
    [super dealloc];
}

@end
