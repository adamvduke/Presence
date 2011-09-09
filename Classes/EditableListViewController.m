/*  EditableListViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 12/23/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "ADSharedMacros.h"
#import "EditableListViewController.h"
#import "FavoritesHelper.h"
#import "PresenceConstants.h"
#import "User.h"

@interface EditableListViewController ()

@property (nonatomic, retain) UIBarButtonItem *addBarButton;
@property (nonatomic, retain) NSMutableArray *pendingFavorites;

@end

/* adding these private methods to the UIAlertView API to avoid
 * compiler warning about possibly not responding to the selector
 */
@interface UIAlertView ()

- (id)addTextFieldWithValue:(id)arg1 label:(id)arg2;
- (id)textFieldAtIndex:(int)arg1;
@end

@implementation EditableListViewController

@synthesize addBarButton, pendingFavorites;

#pragma mark -
#pragma mark Custom Init method

- (id)initWithUserIdArray:(NSMutableArray *)userIds
{
	if(self = [super initWithUserIdArray:userIds])
	{
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
	}
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
	[pendingFavorites release];
	[addBarButton release];
	[super dealloc];
}

#pragma mark -
#pragma mark List Editing

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
			[addButton release];
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
	User *user = [[self.users objectAtIndex:sourceRow] retain];
	NSString *userId = [[self.userIdArray objectAtIndex:sourceRow] retain];
	[self.users removeObjectAtIndex:sourceRow];
	[self.userIdArray removeObjectAtIndex:sourceRow];
	[self.users insertObject:user atIndex:destinationRow];
	[self.userIdArray insertObject:userId atIndex:destinationRow];
	[user release];
	[userId release];
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

- (void)presentAddToFavoritesAlert
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(AddToFavoritesKey, @"")
	                                                message:NSLocalizedString(EnterTwitterIDKey, @"")
	                                               delegate:self
	                                      cancelButtonTitle:NSLocalizedString(CancelKey, @"")
	                                      otherButtonTitles:NSLocalizedString(OKKey, @""), nil];
	[alert addTextFieldWithValue:@"" label:NSLocalizedString(TwitterIDKey, @"")];
	[alert show];
	[alert release];
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
		[super synchronousLoadUser:upperCaseUsername];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	/* Releases the view if it doesn't have a superview. */
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	/* Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	 * For example: self.myOutlet = nil;
	 */
}

#pragma mark -
#pragma mark SA_OAuthTwitterEngineDelegate

- (void)authSucceededForEngine
{
	if( IsEmpty(users) )
	{
		[super synchronousLoadTwitterData];
	}
}

- (void)updateFavoritesWithUser:(User *)user
{
	NSString *upperCaseUsername = [user.screen_name uppercaseString];
	if([pendingFavorites containsObject:upperCaseUsername])
	{
		[userIdArray addObject:user.user_id];
		[FavoritesHelper saveFavorites:userIdArray];
		[pendingFavorites removeObject:upperCaseUsername];
	}
}

- (void)userInfoReceived:(NSDictionary *)userInfo forRequest:(NSString *)connectionIdentifier
{
	User *user = [[User alloc] initWithInfo:userInfo];
	/* this user is not yet in the database */
	if([user isValid])
	{
		[super infoRecievedForUser:user];
		[self updateFavoritesWithUser:user];
	}
	[super didFinishLoadingUser];
	[user release];
}

@end
