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
	// settings
	// favorites
	// following
	// search
	
	tabBarController = [[UITabBarController alloc]init];
	
	// create the view controller for the settings tab
	SettingsViewController *settingsViewController = [[SettingsViewController alloc]initWithNibName:SettingsViewControllerNibName bundle:[NSBundle mainBundle]];
	settingsViewController.tabBarItem.image = [UIImage imageNamed:@"SettingsIcon.png"];
	settingsViewController.title = NSLocalizedString(SettingsViewTitleKey, @"");
	
	// create the navigation controller for the favorites tab
	UINavigationController *favoritesController = [[UINavigationController alloc]init];
	favoritesController.navigationBar.barStyle = UIBarStyleBlack;
	favoritesController.title = @"Favorites";
	favoritesController.tabBarItem.image = [UIImage imageNamed:@"FavoritesIcon.png"];	
	
	// create navigation controller for the following tab
	UINavigationController *navigationController = [[UINavigationController alloc]init];
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// create the list view controller
	ListViewController *listViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain];
	listViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");
	listViewController.tabBarItem.image = [UIImage imageNamed:@"PeopleIcon.png"];
	
	// push the listViewController onto the following navigation stack
	[navigationController pushViewController:listViewController animated:YES];
	
	// release the listViewController
	[listViewController release];
	
	// create the navigation controller for the favorites tab
	UINavigationController *searchController = [[UINavigationController alloc]init];
	searchController.navigationBar.barStyle = UIBarStyleBlack;
	searchController.title = @"Search";
	searchController.tabBarItem.image = [UIImage imageNamed:@"SearchIcon.png"];

	
	tabBarController.viewControllers = [NSArray arrayWithObjects:settingsViewController, favoritesController, navigationController, searchController, nil];
	
	
	// add the navigation controller's view to the window's subviews
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc 
{	
	[tabBarController release];
    [window release];
    [super dealloc];
}
@end
