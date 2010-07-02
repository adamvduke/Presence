//
//  PresenceAppDelegate.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "CredentialHelper.h"
#import "FavoritesHelper.h"
#import "ListViewController.h"
#import "PresenceAppDelegate.h"
#import "PresenceContants.h"
#import "TwitterHelper.h"
#import "ValidationHelper.h"

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

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	// copy the favorites plist to the documents directory
	[FavoritesHelper moveFavoritesToDocumentsDir];
	
	// initialize the tab bar
	tabBarController = [[UITabBarController alloc]init];
	
	// initialize the viewControllerArray
	NSMutableArray *aViewControllerArray = [self initViewControllerArray];
	
	// set the viewControllerArray on the tabBarController
	// and the selected index
	tabBarController.viewControllers = aViewControllerArray;
	[aViewControllerArray release];
	
	tabBarController.selectedIndex = 1;
	
	// add the navigation controller's view to the window's subviews
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}

- (NSMutableArray *)initViewControllerArray
{
	// create the view controller for the settings tab
	SettingsViewController *settingsViewController = [self initSettingsViewController];
	
	// create the view controller for the favorites tab
	UINavigationController *favoritesNavigationController = [self initFavoritesController];	
	
	// create view controller for the following tab
	UINavigationController *followingNavigationController = [self initFollowingController];	
	
	// create the view controller for the search tab
	UINavigationController *searchNavigationController = [self initSearchController];
	
	// add the view controllers to an Array
	NSMutableArray *aViewControllerArray = [[NSMutableArray alloc]init];
	[aViewControllerArray addObject:settingsViewController];
	[aViewControllerArray addObject:favoritesNavigationController];
	[aViewControllerArray addObject:followingNavigationController];
	[aViewControllerArray addObject:searchNavigationController];
	
	// release the view controllers, memory is managed by the NSMutableArray
	[settingsViewController release];
	[favoritesNavigationController release];
	[followingNavigationController release];
	[searchNavigationController release];
	
	return aViewControllerArray;	
}

// initialize the settings view controller from the SettingsViewController.xib
- (SettingsViewController *)initSettingsViewController
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	SettingsViewController *settingsViewController = [[SettingsViewController alloc]initWithNibName:SettingsViewControllerNibName bundle:mainBundle];
	
	// icon image loading
	NSString *iconPath = [mainBundle pathForResource:@"SettingsIcon" ofType:@"png"];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:iconPath];
	settingsViewController.tabBarItem.image = image;
	[image release];
	settingsViewController.title = NSLocalizedString(SettingsViewTitleKey, @"");
	return settingsViewController;
}

// initialize the favorites navigation controller
- (UINavigationController *)initFavoritesController
{
	// create a navigation controller and set it's title and tabBar icon
	UINavigationController *favoritesNavigationController = [[UINavigationController alloc]init];
	
	// icon image loading
	NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"FavoritesIcon" ofType:@"png"];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:iconPath];
	favoritesNavigationController.tabBarItem.image = image;
	[image release];
	favoritesNavigationController.title =  NSLocalizedString(FavoritesViewControllerTitleKey, @"");
	favoritesNavigationController.navigationBar.barStyle = UIBarStyleBlack;

	// get the list of favorites
	NSMutableArray *favoriteUsersArray = [FavoritesHelper retrieveFavorites];

	// initialize a ListViewController with the favoriteUsersArray
	ListViewController *favoritesListViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain editable:YES usernameArray:favoriteUsersArray];
	favoritesListViewController.title = NSLocalizedString(FavoritesViewControllerTitleKey, @"");
	
	// push the followingListViewController onto the following navigation stack and release it
	[favoritesNavigationController pushViewController:favoritesListViewController animated:YES];
	[favoritesListViewController release];
	
	return favoritesNavigationController;
}

// initialize the following navigation controller
- (UINavigationController *)initFollowingController
{
	// create a navigation controller and set it's title and tabBar icon
	UINavigationController *followingNavigationController = [[UINavigationController alloc]init];
	
	// icon image loading
	NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"PeopleIcon" ofType:@"png"];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:iconPath];
	followingNavigationController.tabBarItem.image = image;
	[image release];
	followingNavigationController.title = NSLocalizedString(ListViewControllerTitleKey, @"");
	followingNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// get the username
	NSString *username = [CredentialHelper retrieveUsername];
		
	// ex.[NSThread detachNewThreadSelector:@selector(dowork:) withTarget:self object:someData]; 
	[NSThread detachNewThreadSelector:@selector(initFollowingIdsArrayForUsername:) toTarget:self withObject:username];

	return followingNavigationController;
}

- (void)initFollowingIdsArrayForUsername:(NSString *)username
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

- (void)didFinishLoadingIdsArray:(NSArray *)idArray
{
	// retain the array in case the autorelease pool releases it
	[idArray retain];
	
	// create the list view controller to push on the followingNavigationController
	ListViewController *followingListViewController = [[ListViewController alloc]initWithStyle:UITableViewStylePlain editable:NO usernameArray:idArray];
	followingListViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");
	
	UINavigationController *followingController = [tabBarController.viewControllers objectAtIndex:2];
	[followingController pushViewController:followingListViewController animated:YES];
	[followingListViewController release];
	
	// balance the call to retain
	[idArray release];
}

- (UINavigationController *)initSearchController
{
	UINavigationController *searchNavigationController = [[UINavigationController alloc]init];
	
	// icon image loading
	NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"SearchIcon" ofType:@"png"];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:iconPath];
	searchNavigationController.tabBarItem.image = image;
	[image release];
	searchNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	searchNavigationController.title = NSLocalizedString(SearchViewControllerTitleKey, @"");

	return searchNavigationController;
}

- (void)dealloc 
{	
	[tabBarController release];
    [window release];
    [super dealloc];
}
@end
