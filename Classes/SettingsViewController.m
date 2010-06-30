//
//  SettingsViewController.m
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PresenceContants.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize aNavigationItem;
@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize liveDataLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize liveDataSwitch;
@synthesize delegate;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// return YES for all interface orientations
	return YES;
}

// dismiss the modal view controller
// convenience method for dismissing this view, if presented as a modal view controller
- (IBAction)dismiss
{
	if (self.delegate != nil) {
		[self.delegate didFinishPresentingViewController:self];
	}
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
	[defaults setObject:usernameField.text forKey:UsernameKey];
	[defaults setObject:passwordField.text forKey:PasswordKey];
	[defaults setBool:liveDataSwitch.isOn forKey:LiveDataKey];
	
	// display an alert indicating the values were saved
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(SuccessTitleKey, @"") 
													message:NSLocalizedString(CredentialsSavedMessageKey, @"") 
												   delegate:nil cancelButtonTitle:NSLocalizedString(DismissKey, @"") otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[self hideKeyBoardForTextField:usernameField];
	[self hideKeyBoardForTextField:passwordField];
	
	// after the data is saved, dismiss the modal view controller
	[self dismiss];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// set the views title
	self.aNavigationItem.title = NSLocalizedString(SettingsViewTitleKey, @"");
	
	// localize the labels on the screen
	self.usernameLabel.text = NSLocalizedString(UsernameLabelKey, @"");
	self.passwordLabel.text = NSLocalizedString(PasswordLabelKey, @"");
	self.liveDataLabel.text = NSLocalizedString(LiveDataLabelKey, @"");
	
	// get any values out of NSUserDefaults and set those values on the fields
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.usernameField.text = [defaults objectForKey:UsernameKey];
	self.passwordField.text = [defaults objectForKey:PasswordKey];
	self.liveDataSwitch.on = [defaults boolForKey:LiveDataKey];
	
	// set the clearsOnBeginEditing property to NO, allow the user to decide to delete the current values
	self.usernameField.clearsOnBeginEditing = NO;
	self.passwordField.clearsOnBeginEditing = NO;
	
	// set the secureTextEntry property to YES for the passwordField
	// this cloaks the text in ****** characters
	self.passwordField.secureTextEntry = YES;
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
	[usernameLabel release];
	[passwordLabel release];
	[usernameField release];
	[passwordField release];
	[liveDataSwitch release];
    [super dealloc];
}

@end
