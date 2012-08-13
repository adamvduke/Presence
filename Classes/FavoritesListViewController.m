/*  ListViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "ADEngineBlock.h"
#import "ADSharedMacros.h"
#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "FavoritesHelper.h"
#import "FavoritesListViewController.h"
#import "NINetworkActivity.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"
#import "StatusViewController.h"
#import "User.h"

#define kCustomRowHeight 48  /* height of each row */
#define kThreadBatchCount 5 /* number of rows to create before re-drawing the table view */

@interface FavoritesListViewController ()

@property (nonatomic, strong) UIBarButtonItem *addBarButton;
@property (nonatomic, strong) NSMutableArray *pendingFavorites;

@end

@implementation FavoritesListViewController

@synthesize addBarButton;
@synthesize pendingFavorites;

- (void)presentAddToFavoritesAlert
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(AddToFavoritesKey, @"")
	                                                message:NSLocalizedString(EnterTwitterIDKey, @"")
	                                               delegate:self
	                                      cancelButtonTitle:NSLocalizedString(CancelKey, @"")
	                                      otherButtonTitles:NSLocalizedString(OKKey, @""), nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[[alert textFieldAtIndex:0] setPlaceholder:NSLocalizedString(TwitterIDKey, @"")];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UITextField *textField = [alertView textFieldAtIndex:0];
	NSString *upperCaseUsername = [textField.text uppercaseString];
	if(upperCaseUsername)
	{
		if(!pendingFavorites)
		{
			self.pendingFavorites = [[NSMutableArray alloc] init];
		}
		[pendingFavorites addObject:upperCaseUsername];
		[self startUserLoad:upperCaseUsername];
	}
}

- (void)updateFavoritesWithUser:(User *)user
{
	NSString *upperCaseUsername = [user.screen_name uppercaseString];
	if([pendingFavorites containsObject:upperCaseUsername])
	{
		[self.userIdArray addObject:user.user_id];
		[FavoritesHelper saveFavorites:self.userIdArray];
		[pendingFavorites removeObject:upperCaseUsername];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)startUserLoad:(NSString *)user_id
{
	__block User *user = [self.dataAccessHelper userByUserId:user_id];
	if(![user isValid])
	{
		user = nil;

		/* TODO: the user_id might actually be a string... */
		NSInteger integer = [user_id integerValue];
		NSNumber *number = [NSNumber numberWithInteger:integer];
		NINetworkActivityTaskDidStart();
		[self.engineBlock showUser:[number unsignedLongLongValue] withHandler:^(NSDictionary *result, NSError *error)
		 {
		         NINetworkActivityTaskDidFinish ();
		         user = [[User alloc] initWithInfo:result];

		         /* this user is not yet in the database */
		         if([user isValid])
		         {
		                 [self infoRecievedForUser:user];
		                 [self updateFavoritesWithUser:user];
			 }
		         [self didFinishLoadingUser];
		 }];
	}
	else
	{
		[self.users addObject:user];
		[self didFinishLoadingUser];
	}
}

#pragma mark -
#pragma mark Table view methods
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:YES];
	if(editing)
	{
		if(!self.addBarButton)
		{
			UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
			                                                                           target:self
			                                                                           action:@selector(presentAddToFavoritesAlert)];
			self.addBarButton = addButton;
		}

		/* hold onto the current right bar button (compose) so it can
		 * be put back after editing
		 */
		self.composeBarButton = self.navigationItem.rightBarButtonItem;

		/* set the right bar button to the add bar button */
		self.navigationItem.rightBarButtonItem = self.addBarButton;
	}
	else
	{
		/* set the right bar button to the compose bar button */
		self.navigationItem.rightBarButtonItem = self.composeBarButton;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableview:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	NSUInteger sourceRow = sourceIndexPath.row;
	NSUInteger destinationRow = destinationIndexPath.row;
	User *user = [self.users objectAtIndex:sourceRow];
	NSString *userId = [self.userIdArray objectAtIndex:sourceRow];
	[self.users removeObjectAtIndex:sourceRow];
	[self.userIdArray removeObjectAtIndex:sourceRow];
	[self.users insertObject:user atIndex:destinationRow];
	[self.userIdArray insertObject:userId atIndex:destinationRow];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	/* If row is deleted, remove it from the list. */
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.users removeObjectAtIndex:indexPath.row];
		[self.userIdArray removeObjectAtIndex:indexPath.row];
		[FavoritesHelper saveFavorites:self.userIdArray];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

@end