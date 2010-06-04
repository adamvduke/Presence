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


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	// create navigation controller and add it's view to the window
	navigationController = [[UINavigationController alloc]init];
	
	// set the navigation controller's navigation bar to Black
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// add the navigation controller's view to the window's subviews
	[window addSubview:navigationController.view];
	
	// create the list view controller and push it onto the navigation controller's stack
	ListViewController *listViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain];
	
	// set the listViewController's title to a globally defined string
	[listViewController setTitle:ListViewTitle];
	
	// use the navigation contoller to push a view controller on the stack
	[navigationController pushViewController:listViewController animated:YES];
	
	// release the listViewController, it's memory will now be managed by the navigation controller
	[listViewController release];

    [window makeKeyAndVisible];
}

- (void)dealloc {
	
	[navigationController release];
    [window release];
    [super dealloc];
}
@end
