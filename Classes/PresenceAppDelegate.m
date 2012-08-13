/*  PresenceAppDelegate.m
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright Adam Duke 2009. All rights reserved.
 *
 */

#import "ADEngineBlock.h"
#import "ADSharedMacros.h"
#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "FavoritesHelper.h"
#import "FavoritesListViewController.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"
#import "SettingsViewController.h"

@interface PresenceAppDelegate ()

@property (nonatomic, strong) DataAccessHelper *dataAccessHelper;

- (void)completeLaunchingWithViewControllerIndex:(NSUInteger)index;
- (void)setIconAndTitleForViewController:(UIViewController *)viewController iconName:(NSString *)iconName titleKey:(NSString *)titleKey;
- (id)settingsViewController;
- (id)favoritesController;
- (id)followingController;
- (id)searchController;
- (id)viewControllers;
- (ADEngineBlock *)engineForAuthData:(NSString *)authData;

@end

@implementation PresenceAppDelegate

@synthesize window, tabBarController, dataAccessHelper, engineBlock;

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

    NSString *authData = [CredentialHelper retrieveAuthData];
    if( IsEmpty(authData) )
    {
        ADTwitterOOBViewController *controller = [[ADTwitterOOBViewController alloc] initWithConsumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret delegate:self];
        [self.tabBarController presentModalViewController:controller animated:YES];
        return;
    }
    self.engineBlock = [self engineForAuthData:authData];
    [self completeLaunchingWithViewControllerIndex:1];
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
    viewController.title = NSLocalizedString(titleKey, @"");
}

- (void)completeLaunchingWithViewControllerIndex:(NSUInteger)index
{
    /* set the viewControllerArray on the tabBarController
     * and the selected index
     */
    tabBarController.viewControllers = [self viewControllers];
    tabBarController.selectedIndex = index;
}

#pragma mark -
#pragma mark View Controller initialization
- (NSMutableArray *)viewControllers
{
    /* create the view controller for the settings tab */
    SettingsViewController *settingsViewController = [self settingsViewController];

    /* create the view controller for the favorites tab */
    UINavigationController *favoritesNavigationController = [self favoritesController];

    /* create view controller for the following tab */
    UINavigationController *followingNavigationController = [self followingController];

    /* create the view controller for the search tab */
    UINavigationController *searchNavigationController = [self searchController];

    /* add the view controllers to an Array */
    NSMutableArray *aViewControllerArray = [[NSMutableArray alloc] init];
    [aViewControllerArray addObject:settingsViewController];
    [aViewControllerArray addObject:favoritesNavigationController];
    [aViewControllerArray addObject:followingNavigationController];
    [aViewControllerArray addObject:searchNavigationController];

    return aViewControllerArray;
}

/* initialize the settings view controller from the SettingsViewController.xib */
- (SettingsViewController *)settingsViewController
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:SettingsViewControllerNibName bundle:mainBundle];
    [self setIconAndTitleForViewController:settingsViewController iconName:@"SettingsIcon" titleKey:SettingsViewTitleKey];
    settingsViewController.dataAccessHelper = self.dataAccessHelper;
    return settingsViewController;
}

/* initialize the favorites navigation controller */
- (UINavigationController *)favoritesController
{
    /* create a navigation controller and set it's title and tabBar icon */
    UINavigationController *favoritesNavigationController = [[UINavigationController alloc] init];
    [self setIconAndTitleForViewController:favoritesNavigationController iconName:@"FavoritesIcon" titleKey:FavoritesViewControllerTitleKey];
    favoritesNavigationController.navigationBar.barStyle = UIBarStyleBlack;

    /* get the list of favorites */
    NSMutableArray *favoriteUsersArray = [FavoritesHelper retrieveFavorites];

    /* initialize a ListViewController with the favoriteUsersArray */
    FavoritesListViewController *favoritesListViewController = [[FavoritesListViewController alloc] initWithUserIdArray:favoriteUsersArray];
    favoritesListViewController.dataAccessHelper = self.dataAccessHelper;
    favoritesListViewController.engineBlock = self.engineBlock;
    favoritesListViewController.title = NSLocalizedString(FavoritesViewControllerTitleKey, @"");

    /* push the followingListViewController onto the following navigation stack and release it
    **/
    [favoritesNavigationController pushViewController:favoritesListViewController animated:NO];

    return favoritesNavigationController;
}

/* initialize the following navigation controller */
- (UINavigationController *)followingController
{
    /* create a navigation controller and set it's title and tabBar icon */
    UINavigationController *followingNavigationController = [[UINavigationController alloc] init];
    [self setIconAndTitleForViewController:followingNavigationController iconName:@"PeopleIcon" titleKey:ListViewControllerTitleKey];
    followingNavigationController.navigationBar.barStyle = UIBarStyleBlack;

    UITableViewController *followingListViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    followingListViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");

    [followingNavigationController pushViewController:followingListViewController animated:NO];
    return followingNavigationController;
}

/* initialize the search navigation controller */
- (UINavigationController *)searchController
{
    UINavigationController *searchNavigationController = [[UINavigationController alloc] init];
    [self setIconAndTitleForViewController:searchNavigationController iconName:@"SearchIcon" titleKey:SearchViewControllerTitleKey];

    /* TODO: push a UIViewController with the ability to search the twitter api */
    searchNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    return searchNavigationController;
}

- (ADEngineBlock *)engineForAuthData:(NSString *)authData
{
    return [[ADEngineBlock alloc] initWithAuthData:authData consumerKey:kOAuthConsumerKey consumerSecret:kOAuthConsumerSecret];
}

- (void)authCompletedWithData:(NSString *)authData orError:(NSError *)error
{
    [CredentialHelper saveAuthData:authData];
    self.engineBlock = [self engineForAuthData:authData];
    [self completeLaunchingWithViewControllerIndex:1];
    [self.tabBarController dismissModalViewControllerAnimated:YES];
}

- (void)authCancelled
{
    [self completeLaunchingWithViewControllerIndex:1];
    [self.tabBarController dismissModalViewControllerAnimated:YES];
}

@end