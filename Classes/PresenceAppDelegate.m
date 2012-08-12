/*  PresenceAppDelegate.m
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright Adam Duke 2009. All rights reserved.
 *
 */

#import "ADSharedMacros.h"
#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "EditableListViewController.h"
#import "FavoritesHelper.h"
#import "ListViewController.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"
#import "SettingsViewController.h"

@interface PresenceAppDelegate ()

@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;

- (void)completeLaunchingWithViewControllerIndex:(NSUInteger)index;
- (void)setIconAndTitleForViewController:(UIViewController *)viewController iconName:(NSString *)iconName titleKey:(NSString *)titleKey;
- (SettingsViewController *)initSettingsViewController;
- (UINavigationController *)initFavoritesController;
- (UINavigationController *)initFollowingController;
- (UINavigationController *)initSearchController;
- (NSMutableArray *)initViewControllers;

@end

@implementation PresenceAppDelegate

@synthesize window, dataAccessHelper, tabBarController;

#pragma mark -
#pragma mark UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	/* initialize the tab bar */
	tabBarController = [[UITabBarController alloc] init];

	/* add the tabBarController's view to the window */
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];

	/* copy the favorites plist to the documents directory */
	[FavoritesHelper moveFavoritesToDocumentsDir];

	dataAccessHelper = [[DataAccessHelper alloc] init];
	if(![dataAccessHelper createAndValidateDatabase])
	{
		NSLog(@"Error creating database");
	}
}

#pragma mark -
#pragma mark Helper methods

/*
 * Helper method to set the image and title for a view controller
 */
- (void)setIconAndTitleForViewController:(UIViewController *)viewController iconName:(NSString *)iconName titleKey:(NSString *)titleKey
{
	/* icon image loading */
	NSString *iconPath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:iconPath];
	viewController.tabBarItem.image = image;
	[image release];
	viewController.title = NSLocalizedString(titleKey, @"");
}

- (void)completeLaunchingWithViewControllerIndex:(NSUInteger)index
{
	/* initialize the viewControllerArray */
	NSMutableArray *aViewControllerArray = [self initViewControllers];

	/* set the viewControllerArray on the tabBarController
	 * and the selected index
	 */
	tabBarController.viewControllers = aViewControllerArray;
	[aViewControllerArray release];

	tabBarController.selectedIndex = index;
}

#pragma mark -
#pragma mark View Controller initialization
- (NSMutableArray *)initViewControllers
{
	/* create the view controller for the settings tab */
	SettingsViewController *settingsViewController = [self initSettingsViewController];

	/* create the view controller for the favorites tab */
	UINavigationController *favoritesNavigationController = [self initFavoritesController];

	/* create view controller for the following tab */
	UINavigationController *followingNavigationController = [self initFollowingController];

	/* create the view controller for the search tab */
	UINavigationController *searchNavigationController = [self initSearchController];

	/* add the view controllers to an Array */
	NSMutableArray *aViewControllerArray = [[NSMutableArray alloc] init];
	[aViewControllerArray addObject:settingsViewController];
	[aViewControllerArray addObject:favoritesNavigationController];
	[aViewControllerArray addObject:followingNavigationController];
	[aViewControllerArray addObject:searchNavigationController];

	/* release the view controllers, memory is managed by the NSMutableArray */
	[settingsViewController release];
	[favoritesNavigationController release];
	[followingNavigationController release];
	[searchNavigationController release];

	return aViewControllerArray;
}

/* initialize the settings view controller from the SettingsViewController.xib */
- (SettingsViewController *)initSettingsViewController
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:SettingsViewControllerNibName bundle:mainBundle];
	[self setIconAndTitleForViewController:settingsViewController iconName:@"SettingsIcon" titleKey:SettingsViewTitleKey];
	settingsViewController.dataAccessHelper = self.dataAccessHelper;
	return settingsViewController;
}

/* initialize the favorites navigation controller */
- (UINavigationController *)initFavoritesController
{
	/* create a navigation controller and set it's title and tabBar icon */
	UINavigationController *favoritesNavigationController = [[UINavigationController alloc] init];
	[self setIconAndTitleForViewController:favoritesNavigationController iconName:@"FavoritesIcon" titleKey:FavoritesViewControllerTitleKey];
	favoritesNavigationController.navigationBar.barStyle = UIBarStyleBlack;

	/* get the list of favorites */
	NSMutableArray *favoriteUsersArray = [FavoritesHelper retrieveFavorites];

	/* initialize a ListViewController with the favoriteUsersArray */
	ListViewController *favoritesListViewController = [[EditableListViewController alloc] initWithUserIdArray:favoriteUsersArray];
	favoritesListViewController.dataAccessHelper = self.dataAccessHelper;
	favoritesListViewController.title = NSLocalizedString(FavoritesViewControllerTitleKey, @"");

	/* push the followingListViewController onto the following navigation stack and release it
	**/
	[favoritesNavigationController pushViewController:favoritesListViewController animated:NO];
	[favoritesListViewController release];

	return favoritesNavigationController;
}

/* initialize the following navigation controller */
- (UINavigationController *)initFollowingController
{
	/* create a navigation controller and set it's title and tabBar icon */
	UINavigationController *followingNavigationController = [[UINavigationController alloc] init];
	[self setIconAndTitleForViewController:followingNavigationController iconName:@"PeopleIcon" titleKey:ListViewControllerTitleKey];
	followingNavigationController.navigationBar.barStyle = UIBarStyleBlack;

	NSMutableArray *followingUsersArray = nil;
	ListViewController *followingListViewController = [[ListViewController alloc] initWithUserIdArray:followingUsersArray];
	followingListViewController.dataAccessHelper = self.dataAccessHelper;
	followingListViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");

	[followingNavigationController pushViewController:followingListViewController animated:NO];
	[followingListViewController release];

	NSString *username = [CredentialHelper retrieveUsername];

	return followingNavigationController;
}

/* initialize the search navigation controller */
- (UINavigationController *)initSearchController
{
	UINavigationController *searchNavigationController = [[UINavigationController alloc] init];
	[self setIconAndTitleForViewController:searchNavigationController iconName:@"SearchIcon" titleKey:SearchViewControllerTitleKey];

	/* TODO: push a UIViewController with the ability to search the twitter api */
	searchNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	return searchNavigationController;
}

#pragma mark -
#pragma mark NSObject
- (void)dealloc
{
	[window release];
	[dataAccessHelper release];
	[tabBarController release];
	[super dealloc];
}

@end