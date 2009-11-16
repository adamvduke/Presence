//
//  PresenceAppDelegate.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "PresenceAppDelegate.h"
#import "PersonListViewController.h"

@implementation PresenceAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	navigationController = [[UINavigationController alloc]init];
	[window addSubview:navigationController.view];
	
	//Instantiate the list view and push it on the navigation controller stack
	PersonListViewController *listViewController = [[PersonListViewController alloc]initWithNibName:@"ListView" bundle:[NSBundle mainBundle]];
	[listViewController setTitle:@"People"];
	[navigationController pushViewController:listViewController animated:NO];
	[listViewController release];
	
	// Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
	
	[navigationController release];
    [window release];
    [super dealloc];
}


@end
