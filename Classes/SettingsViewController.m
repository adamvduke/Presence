/*  SettingsViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 6/3/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "PresenceAppDelegate.h"
#import "PresenceContants.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize aNavigationItem, deauthorizeButton, dataAccessHelper;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	/* return YES for all interface orientations */
	return YES;
}

- (IBAction)deauthorize
{
	PresenceAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	[appDelegate deauthorizeEngines];
}

- (IBAction)deleteData
{
	[self.dataAccessHelper deleteAllData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	/* set the views title */
	self.aNavigationItem.title = NSLocalizedString(SettingsViewTitleKey, @"");
}

- (void)didReceiveMemoryWarning
{
	/* Releases the view if it doesn't have a superview. */
	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[self.dataAccessHelper release];
	[super dealloc];
}

@end