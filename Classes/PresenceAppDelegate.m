//
//  PresenceAppDelegate.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright Adam Duke 2009. All rights reserved.
//

#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "FavoritesHelper.h"
#import "ListViewController.h"
#import "PresenceAppDelegate.h"
#import "PresenceContants.h"
#import "TwitterHelper.h"
#import "ValidationHelper.h"

@interface PresenceAppDelegate (Private)

- (SettingsViewController *)initSettingsViewController;
- (UINavigationController *)initFavoritesController;
- (UINavigationController *)initFollowingController;
- (UINavigationController *)initSearchController;
- (NSMutableArray *)initViewControllerArray;
- (void)didFinishLoadingIdsArray:(NSArray *)idArray;

@end

@implementation PresenceAppDelegate

@synthesize window;
@synthesize dataAccessHelper;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	// copy the favorites plist to the documents directory
	[FavoritesHelper moveFavoritesToDocumentsDir];
	
	dataAccessHelper = [[DataAccessHelper alloc]init];
	BOOL databaseExists = [dataAccessHelper createAndValidateDatabase];
	if (!databaseExists) {
		NSLog(@"Error creating database");
	}
	
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

- (UIViewController *)setIconAndTitleForViewController:(UIViewController *)viewController iconName:(NSString *)iconName titleKey:(NSString *)titleKey
{
	// icon image loading
	NSString *iconPath = [[NSBundle mainBundle]pathForResource:iconName ofType:@"png"];
	UIImage *image = [[UIImage alloc]initWithContentsOfFile:iconPath];
	viewController.tabBarItem.image = image;
	[image release];
	viewController.title = NSLocalizedString(titleKey, @"");
	
	return viewController;
}

// initialize the settings view controller from the SettingsViewController.xib
- (SettingsViewController *)initSettingsViewController
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	SettingsViewController *settingsViewController = [[SettingsViewController alloc]
													  initWithNibName:SettingsViewControllerNibName bundle:mainBundle];
	settingsViewController = (SettingsViewController *)[self setIconAndTitleForViewController:settingsViewController 
																					 iconName:@"SettingsIcon" titleKey:SettingsViewTitleKey];
	return settingsViewController;
}

// initialize the favorites navigation controller
- (UINavigationController *)initFavoritesController
{
	// create a navigation controller and set it's title and tabBar icon
	UINavigationController *favoritesNavigationController = [[UINavigationController alloc]init];
	favoritesNavigationController = (UINavigationController *)[self setIconAndTitleForViewController:favoritesNavigationController 
																							iconName:@"FavoritesIcon" 
																							titleKey:FavoritesViewControllerTitleKey];
	favoritesNavigationController.navigationBar.barStyle = UIBarStyleBlack;

	// get the list of favorites
	NSMutableArray *favoriteUsersArray = [FavoritesHelper retrieveFavorites];

	// initialize a ListViewController with the favoriteUsersArray
	ListViewController *favoritesListViewController = [[ListViewController alloc]initAsEditable:YES userIdArray:favoriteUsersArray dataAccessHelper:dataAccessHelper];
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
	followingNavigationController = (UINavigationController *)[self setIconAndTitleForViewController:followingNavigationController 
																							iconName:@"PeopleIcon" 
																							titleKey:ListViewControllerTitleKey];
	followingNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// get the username
	NSString *screenName = [CredentialHelper retrieveScreenName];
		
	// ex.[NSThread detachNewThreadSelector:@selector(dowork:) withTarget:self object:someData]; 
	[NSThread detachNewThreadSelector:@selector(initFollowingIdsArrayForScreenName:) toTarget:self withObject:screenName];

	return followingNavigationController;
}

// initialize the search navigation controller
- (UINavigationController *)initSearchController
{
	UINavigationController *searchNavigationController = [[UINavigationController alloc]init];
	searchNavigationController = (UINavigationController *)[self setIconAndTitleForViewController:searchNavigationController 
																						 iconName:@"SearchIcon" 
																						 titleKey:SearchViewControllerTitleKey];	
	searchNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	return searchNavigationController;
}

- (void)initFollowingIdsArrayForScreenName:(NSString *)screenName
{
	// init an autorelease pool for a detached thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
		
	// fetch the names from twitter
	NSMutableArray *idsArray = [TwitterHelper fetchFollowingIdsForScreenName:screenName];
	
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
	ListViewController *followingListViewController = [[ListViewController alloc]initAsEditable:NO userIdArray:idArray dataAccessHelper:dataAccessHelper];
	followingListViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");
	
	UINavigationController *followingController = [tabBarController.viewControllers objectAtIndex:2];
	[followingController pushViewController:followingListViewController animated:YES];
	[followingListViewController release];
	
	// balance the call to retain
	[idArray release];
}

- (void)dealloc 
{	
	[tabBarController release];
    [window release];
	[dataAccessHelper release];
    [super dealloc];
}
@end
