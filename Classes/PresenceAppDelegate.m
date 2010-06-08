//
//  PresenceAppDelegate.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ListViewController.h"
#import "PresenceAppDelegate.h"
#import "PresenceContants.h"


@implementation PresenceAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// create navigation controller
	navigationController = [[UINavigationController alloc]init];
	
	// set the navigation controller's navigation bar to Black
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// add the navigation controller's view to the window's subviews
	[window addSubview:navigationController.view];
	
	// create the list view controller
	ListViewController *listViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain];
	
	// set the listViewController's title to a localized string
	NSString *title = NSLocalizedString(ListViewControllerTitleKey, @"");
	[listViewController setTitle:title];
	
	// push the listViewController onto the navigation stack
	[navigationController pushViewController:listViewController animated:YES];
	
	// release the listViewController
	[listViewController release];
	
    [window makeKeyAndVisible];
}

- (void)dealloc 
{	
	[navigationController release];
    [window release];
    [super dealloc];
}
@end
