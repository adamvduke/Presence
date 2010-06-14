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

-(SettingsViewController *)initSettingsViewController
{
	SettingsViewController *settingsViewController = [[SettingsViewController alloc]initWithNibName:SettingsViewControllerNibName bundle:[NSBundle mainBundle]];
	settingsViewController.tabBarItem.image = [UIImage imageNamed:@"SettingsIcon.png"];
	settingsViewController.title = NSLocalizedString(SettingsViewTitleKey, @"");
	return settingsViewController;
}

-(UINavigationController *)initFavoritesController
{
	UINavigationController *favoritesNavigationController = [[UINavigationController alloc]init];
	favoritesNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	ListViewController *favoritesListViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain listName:@"FavoriteUsers"];
	favoritesListViewController.title = NSLocalizedString(FavoritesViewControllerTitleKey, @"");
	favoritesListViewController.tabBarItem.image = [UIImage imageNamed:@"FavoritesIcon.png"];	
	
	// push the followingListViewController onto the following navigation stack and release it
	[favoritesNavigationController pushViewController:favoritesListViewController animated:YES];
	[favoritesListViewController release];
	
	return favoritesNavigationController;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	tabBarController = [[UITabBarController alloc]init];
	
	// create the view controller for the settings tab
	SettingsViewController *settingsViewController = [self initSettingsViewController];
	
	// create the view controller for the favorites tab
	UINavigationController *favoritesNavigationController = [self initFavoritesController];	
	// create view controller for the following tab
	UINavigationController *followingNavigationController = [[UINavigationController alloc]init];
	followingNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// create the list view controller to push on the followingNavigationController
	ListViewController *followingListViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain listName:nil];
	followingListViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");
	followingListViewController.tabBarItem.image = [UIImage imageNamed:@"PeopleIcon.png"];
	
	// push the followingListViewController onto the following navigation stack and release it
	[followingNavigationController pushViewController:followingListViewController animated:YES];
	[followingListViewController release];
	
	// create the view controller for the search tab
	UINavigationController *searchNavigationController = [[UINavigationController alloc]init];
	searchNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	searchNavigationController.title = NSLocalizedString(SearchViewControllerTitleKey, @"");
	searchNavigationController.tabBarItem.image = [UIImage imageNamed:@"SearchIcon.png"];

	NSMutableArray *viewControllerArray = [[NSMutableArray alloc]init];
	[viewControllerArray addObject:settingsViewController];
	[viewControllerArray addObject:favoritesNavigationController];
	[viewControllerArray addObject:followingListViewController];
	[viewControllerArray addObject:searchNavigationController];
	
	tabBarController.viewControllers = viewControllerArray;
	tabBarController.selectedViewController = favoritesNavigationController;
	
	[viewControllerArray release];
	[settingsViewController release];
	[favoritesNavigationController release];
	[followingNavigationController release];
	[searchNavigationController release];
	
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
