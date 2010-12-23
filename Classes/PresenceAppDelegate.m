/*  PresenceAppDelegate.m
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright Adam Duke 2009. All rights reserved.
 *
 */

#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "FavoritesHelper.h"
#import "ListViewController.h"
#import "PresenceAppDelegate.h"
#import "PresenceContants.h"
#import "ValidationHelper.h"
#import <dispatch/dispatch.h>

typedef enum
{
	RateLimitRequest,
	FollowedIdsRequest
} RequestType;

@interface PresenceAppDelegate ()

@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;
@property (nonatomic, retain) NSMutableDictionary *openRequests;
@property (nonatomic, retain) SA_OAuthTwitterEngine *engine;

- (void)completeLaunchingWithViewControllerIndex:(NSUInteger)index;
- (void)cacheRequestType:(NSNumber *)requestType forConnectionId:(NSString *)connectionId;
- (UIViewController *)initIconAndTitleForViewController:(UIViewController *)viewController iconName:(NSString *)iconName titleKey:(NSString *)titleKey;
- (SettingsViewController *)initSettingsViewController;
- (UINavigationController *)initFavoritesController;
- (UINavigationController *)initFollowingController;
- (void)recievedFollowingIdsResponse:(NSArray *)response;
- (void)updateFollowingControllerWithArray:(NSMutableArray *)idsArray;
- (UINavigationController *)initSearchController;
- (NSMutableArray *)initViewControllers;

@end

@implementation PresenceAppDelegate

@synthesize window, dataAccessHelper, openRequests, engine;

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

	self.engine = [self getEngineForDelegate:self];
	if([self.engine isAuthorized])
	{
		[self authSucceededForEngine];
	}
}

#pragma mark -
#pragma mark Helper methods

/*
 * Helper method to set the image and title for a view controller
 */
- (UIViewController *)initIconAndTitleForViewController:(UIViewController *)viewController iconName:(NSString *)iconName titleKey:(NSString *)titleKey
{
	/* icon image loading */
	NSString *iconPath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:iconPath];
	viewController.tabBarItem.image = image;
	[image release];
	viewController.title = NSLocalizedString(titleKey, @"");

	return viewController;
}

/*
 * Cache the RequestType for a particular connectionId so that a decision can be made
 * later about how to handle the response.
 */
- (void)cacheRequestType:(NSNumber *)requestType forConnectionId:(NSString *)connectionId
{
	if(!openRequests)
	{
		openRequests = [[NSMutableDictionary alloc] init];
	}
	if(connectionId)
	{
		[openRequests setObject:requestType forKey:connectionId];
	}
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
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:SettingsViewControllerNibName
	                                                                                          bundle:mainBundle];
	settingsViewController = (SettingsViewController *)[self initIconAndTitleForViewController:settingsViewController
	                                                                                  iconName:@"SettingsIcon"
	                                                                                  titleKey:SettingsViewTitleKey];
	settingsViewController.dataAccessHelper = self.dataAccessHelper;
	return settingsViewController;
}

/* initialize the favorites navigation controller */
- (UINavigationController *)initFavoritesController
{
	/* create a navigation controller and set it's title and tabBar icon */
	UINavigationController *favoritesNavigationController = [[UINavigationController alloc] init];
	favoritesNavigationController = (UINavigationController *)[self initIconAndTitleForViewController:favoritesNavigationController
	                                                                                         iconName:@"FavoritesIcon"
	                                                                                         titleKey:FavoritesViewControllerTitleKey];
	favoritesNavigationController.navigationBar.barStyle = UIBarStyleBlack;

	/* get the list of favorites */
	NSMutableArray *favoriteUsersArray = [FavoritesHelper retrieveFavorites];

	/* initialize a ListViewController with the favoriteUsersArray */
	ListViewController *favoritesListViewController = [[ListViewController alloc] initAsEditable:YES userIdArray:favoriteUsersArray];
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
	followingNavigationController = (UINavigationController *)[self initIconAndTitleForViewController:followingNavigationController
	                                                                                         iconName:@"PeopleIcon"
	                                                                                         titleKey:ListViewControllerTitleKey];
	followingNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	NSString *username = [CredentialHelper retrieveUsername];
	NSString *connectionId = [self.engine getFollowedIdsForUsername:username];
	[self cacheRequestType:[NSNumber numberWithInt:FollowedIdsRequest] forConnectionId:connectionId];
	return followingNavigationController;
}

/*
 * Parse the ids out of the response and call to update the
 * followingNavigationController
 */
- (void)recievedFollowingIdsResponse:(NSArray *)response
{
	NSMutableArray *idsArray = [NSMutableArray array];
	for(NSDictionary *dictionary in response)
	{
		for(NSString *key in [dictionary allKeys])
		{
			[idsArray addObject:[dictionary objectForKey:key]];
		}
	}
	[self updateFollowingControllerWithArray:idsArray];
}

/*
 * Initialize a ListViewController with the ids and set it push it
 * onto the stack of UIViewControllers on the followingNavigationController
 */
- (void)updateFollowingControllerWithArray:(NSMutableArray *)idsArray
{
	ListViewController *followingListViewController = [[ListViewController alloc] initAsEditable:NO userIdArray:idsArray];
	followingListViewController.dataAccessHelper = self.dataAccessHelper;
	followingListViewController.title = NSLocalizedString(ListViewControllerTitleKey, @"");

	UINavigationController *followingController = [tabBarController.viewControllers objectAtIndex:2];
	[followingController pushViewController:followingListViewController animated:NO];
	[followingListViewController release];
}

/* initialize the search navigation controller */
- (UINavigationController *)initSearchController
{
	UINavigationController *searchNavigationController = [[UINavigationController alloc] init];
	searchNavigationController = (UINavigationController *)[self initIconAndTitleForViewController:searchNavigationController
	                                                                                      iconName:@"SearchIcon"
	                                                                                      titleKey:SearchViewControllerTitleKey];

	/* TODO: push a UIViewController with the ability to search the twitter api */
	searchNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	return searchNavigationController;
}

#pragma mark -
#pragma mark SA_OAuthTwitterControllerDelegate

- (void)OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username
{
	/* save the username */
	[CredentialHelper saveUsername:username];

	/* log the username for debug purposes */
	NSLog(@"Authenicated for %@", username);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	/* tabBarController.selectedIndex = 0; */
	[self completeLaunchingWithViewControllerIndex:0];
}

- (void)OAuthTwitterControllerFailed:(SA_OAuthTwitterController *)controller
{
	tabBarController.selectedIndex = 0;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(AuthFailedTitleKey, @"")
	                                                message:NSLocalizedString(AuthFailedMessageKey, @"")
	                                               delegate:self
	                                      cancelButtonTitle:NSLocalizedString(DismissKey, @"")
	                                      otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)controller
{
	if(tabBarController.modalViewController)
	{
		[tabBarController dismissModalViewControllerAnimated:YES];
	}
}

- (SA_OAuthTwitterEngine *)getEngineForDelegate:(id)engineDelegate
{
	/* initialize the twitter engine and present the modal view controller
	 * to enter credentials if the engine is not authorized
	 */
	SA_OAuthTwitterEngine *anEngine = [[[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:engineDelegate] autorelease];
	anEngine.consumerKey = kOAuthConsumerKey;
	anEngine.consumerSecret = kOAuthConsumerSecret;

	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:anEngine delegate:self];
	if(controller)
	{
		if([engineDelegate respondsToSelector:@selector(presentModalViewController:animated:)])
		{
			[engineDelegate presentModalViewController:controller animated:NO];
		}
		else
		{
			[tabBarController presentModalViewController:controller animated:NO];
		}
	}
	return anEngine;
}

/* deauthrorize all engines in the NSArray of delegates
 * as well as any engines in child view controllers
 */
- (void)deauthorizeEngines:(NSArray *)delegates
{
	for(id potentialDelegate in delegates)
	{
		if([potentialDelegate respondsToSelector:@selector(deauthorizeEngine)])
		{
			[potentialDelegate deauthorizeEngine];
		}
		if([potentialDelegate respondsToSelector:@selector(viewControllers)])
		{
			id viewControllers = [potentialDelegate viewControllers];
			if([viewControllers isKindOfClass:[NSArray class]])
			{
				[self deauthorizeEngines:viewControllers];
			}
		}
	}
}

/* deauthorize all engines */
- (void)deauthorizeEngines
{
	[self deauthorizeEngine];
	NSArray *viewControllers = tabBarController.viewControllers;
	[self deauthorizeEngines:viewControllers];
}

#pragma mark -
#pragma mark SA_OAuthTwitterEngineDelegate
- (void)storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username
{
	[CredentialHelper saveAuthData:data];
	[CredentialHelper saveUsername:username];
}

- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *)username
{
	NSString *authData = [CredentialHelper retrieveAuthData];
	return authData;
}

- (void)authSucceededForEngine
{
	[self completeLaunchingWithViewControllerIndex:1];
}

- (void)deauthorizeEngine
{
	[self.engine clearAccessToken];
}

#pragma mark -
#pragma mark EngineDelegate

/* These delegate methods are called after a connection has been established */
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Request succeeded %@, response pending.\n", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Request failed %@, with error %@.", connectionIdentifier, [error localizedDescription]);
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
	NSNumber *requestType = [openRequests objectForKey:connectionIdentifier];
	switch([requestType intValue])
	{
	case RateLimitRequest:
		break;
	case FollowedIdsRequest:
		[self recievedFollowingIdsResponse:miscInfo];
		break;
	default:
		break;
	}
	[openRequests removeObjectForKey:connectionIdentifier];
}

#pragma mark -
#pragma mark NSObject
- (void)dealloc
{
	[tabBarController release];
	[window release];
	[dataAccessHelper release];
	[super dealloc];
}

@end