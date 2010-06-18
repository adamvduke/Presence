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
#import "TwitterHelper.h"

@interface PresenceAppDelegate ()

- (SettingsViewController *)initSettingsViewController;
- (UINavigationController *)initFavoritesController;
- (UINavigationController *)initFollowingController;
- (UINavigationController *)initSearchController;
- (NSMutableArray *)initViewControllerArray;
- (void)didFinishLoadingIdsArray:(NSArray *)idArray;

@end

@implementation PresenceAppDelegate

@synthesize window;
@synthesize viewControllerArray;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	tabBarController = [[UITabBarController alloc]init];
	
	self.viewControllerArray = [self initViewControllerArray];
	
	tabBarController.viewControllers = viewControllerArray;
	tabBarController.selectedIndex = 1;
	
	[viewControllerArray release];
	
	// add the navigation controller's view to the window's subviews
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}

-(NSMutableArray *)initViewControllerArray
{
	// create the view controller for the settings tab
	SettingsViewController *settingsViewController = [self initSettingsViewController];
	
	// create the view controller for the favorites tab
	UINavigationController *favoritesNavigationController = [self initFavoritesController];	
	
	// create view controller for the following tab
	UINavigationController *followingNavigationController = [self initFollowingController];	
	
	// create the view controller for the search tab
	UINavigationController *searchNavigationController = [self initSearchController];
	
	NSMutableArray *aViewControllerArray = [[NSMutableArray alloc]init];
	[aViewControllerArray addObject:settingsViewController];
	[aViewControllerArray addObject:favoritesNavigationController];
	[aViewControllerArray addObject:followingNavigationController];
	[aViewControllerArray addObject:searchNavigationController];
	
	[settingsViewController release];
	[favoritesNavigationController release];
	[followingNavigationController release];
	[searchNavigationController release];
	
	return aViewControllerArray;	
}

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
	favoritesNavigationController.title =  NSLocalizedString(FavoritesViewControllerTitleKey, @"");
	favoritesNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	favoritesNavigationController.tabBarItem.image = [UIImage imageNamed:@"FavoritesIcon.png"];	

	NSString *path = [[NSBundle mainBundle]pathForResource:@"FavoriteUsers" ofType:@"plist"];
	NSArray *favoriteUsersArray = [NSArray arrayWithContentsOfFile:path];

	ListViewController *favoritesListViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain usernameArray:favoriteUsersArray];
	favoritesListViewController.title = NSLocalizedString(FavoritesViewControllerTitleKey, @"");
	
	// push the followingListViewController onto the following navigation stack and release it
	[favoritesNavigationController pushViewController:favoritesListViewController animated:YES];
	[favoritesListViewController release];
	
	return favoritesNavigationController;
}

-(UINavigationController *)initFollowingController
{
	UINavigationController *followingNavigationController = [[UINavigationController alloc]init];
	followingNavigationController.title = NSLocalizedString(ListViewControllerTitleKey, @"");
	followingNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	followingNavigationController.tabBarItem.image = [UIImage imageNamed:@"PeopleIcon.png"];
	
	NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:UsernameKey];

	// ex.[NSThread detachNewThreadSelector:@selector(dowork:) withTarget:self object:someData]; 
	[NSThread detachNewThreadSelector:@selector(initFollowingIdsArrayForUsername:) toTarget:self withObject:username];

	return followingNavigationController;
}

-(void)initFollowingIdsArrayForUsername:(NSString *)username
{
	// init an autorelease pool for a detached thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	// fetch the names from the data source
	NSArray *idsArray = [TwitterHelper fetchFollowingIdsForUsername:username];
	
	// perform the did finish selector on the main thread because UIKit classes
	// can't act on a detached thread
	[self performSelectorOnMainThread:@selector(didFinishLoadingIdsArray:) withObject:idsArray waitUntilDone:NO];
	[pool release];
}

-(void)didFinishLoadingIdsArray:(NSArray *)idArray
{
	// retain the array in case the autorelease pool releases it
	[idArray retain];
	
	// create the list view controller to push on the followingNavigationController
	ListViewController *followingListViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain usernameArray:idArray];
	followingListViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");
	
	UINavigationController *followingController = [self.viewControllerArray objectAtIndex:2];
	[followingController pushViewController:followingListViewController animated:YES];
	[followingListViewController release];
	
	// balance the call to retain
	[idArray release];
}

-(UINavigationController *)initSearchController
{
	UINavigationController *searchNavigationController = [[UINavigationController alloc]init];
	searchNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	searchNavigationController.title = NSLocalizedString(SearchViewControllerTitleKey, @"");
	searchNavigationController.tabBarItem.image = [UIImage imageNamed:@"SearchIcon.png"];

	return searchNavigationController;
}

- (void)dealloc 
{	
	[tabBarController release];
    [window release];
    [super dealloc];
}
@end
