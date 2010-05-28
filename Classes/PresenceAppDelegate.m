//
//  PresenceAppDelegate.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "PresenceAppDelegate.h"
#import "ListViewController.h"

@implementation PresenceAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	//create navigation controller and add it's view to the window
	navigationController = [[UINavigationController alloc]init];
	[window addSubview:navigationController.view];
	
	//create the list view controller and push it onto the navigation controller's stack
	ListViewController *listViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain];
	[listViewController setTitle:@"People"];
	[navigationController pushViewController:listViewController animated:YES];
	[listViewController release];

    [window makeKeyAndVisible];
}

- (void)dealloc {
	
	[navigationController release];
    [window release];
    [super dealloc];
}
@end
