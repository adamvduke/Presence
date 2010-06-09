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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// return YES for all interface orientations
	return YES;
}

// dismiss the modal view controller
-(IBAction)dismiss
{
	[self.delegate didFinishPresentingViewController:self];
}

// save the state of the settings to NSUserDefaults
-(IBAction)save
{	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:usernameField.text forKey:UsernameKey];
	[defaults setObject:passwordField.text forKey:PasswordKey];
	[defaults setBool:liveDataSwitch.isOn forKey:LiveDataKey];
	
	// after the data is saved, dismiss the modal view controller
	[self dismiss];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// set the views title
	self.aNavigationItem.title = NSLocalizedString(SettingsViewTitleKey, @"");
	
	// localize the labels on the screen
	usernameLabel.text = NSLocalizedString(UsernameLabelKey, @"");
	passwordLabel.text = NSLocalizedString(PasswordLabelKey, @"");
	liveDataLabel.text = NSLocalizedString(LiveDataLabelKey, @"");
	
	// get any values out of NSUserDefaults and set those values on the fields
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	usernameField.text = [defaults objectForKey:UsernameKey];
	passwordField.text = [defaults objectForKey:PasswordKey];
	liveDataSwitch.on = [defaults boolForKey:LiveDataKey];
	
	// set the clearsOnBeginEditing property to NO, allow the user to decide to delete the current values
	usernameField.clearsOnBeginEditing = NO;
	passwordField.clearsOnBeginEditing = NO;
	
	// set the secureTextEntry property to YES for the passwordField
	// this cloaks the text in ****** characters
	passwordField.secureTextEntry = YES;
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