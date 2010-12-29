/*  EditableListViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 12/23/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "EditableListViewController.h"
#import "FavoritesHelper.h"
#import "Person.h"
#import "ValidationHelper.h"

@interface EditableListViewController ()

@property (nonatomic, retain) UIBarButtonItem *addBarButton;
@property (nonatomic, retain) NSMutableArray *pendingFavorites;

@end

@implementation EditableListViewController

@synthesize addBarButton, pendingFavorites;

#pragma mark -
#pragma mark Custom Init method

- (id)initWithUserIdArray:(NSMutableArray *)userIds
{
	if(self == [super initWithUserIdArray:userIds])
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
	Person *person = [[self.people objectAtIndex:sourceRow] retain];
	NSString *userId = [[self.userIdArray objectAtIndex:sourceRow] retain];
	[self.people removeObjectAtIndex:sourceRow];
	[self.userIdArray removeObjectAtIndex:sourceRow];
	[self.people insertObject:person atIndex:destinationRow];
	[self.userIdArray insertObject:userId atIndex:destinationRow];
	[person release];
	[userId release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	/* If row is deleted, remove it from the list. */
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.people removeObjectAtIndex:indexPath.row];
		[self.userIdArray removeObjectAtIndex:indexPath.row];
		[FavoritesHelper saveFavorites:self.userIdArray];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)presentAddToFavoritesAlert
{
	/* TODO: localize the alert message labels
	 * TODO: Decide if the alertview with a text field is appropriate
	 * or if a modal view should be used, or if the favorites should be
	 * added to from the status views with a "Favorite" button
	 * open a alert with text field,  OK and cancel button
	 */
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add to Favorites"
	                                                message:@"Enter a username."
	                                               delegate:self
	                                      cancelButtonTitle:@"Cancel"
	                                      otherButtonTitles:@"OK", nil];
	UITextView *alertTextField = nil;
	CGRect frame = CGRectMake(14, 45, 255, 23);
	if(!alertTextField)
	{
		alertTextField = [[UITextField alloc] initWithFrame:frame];
		alertTextField.layer.cornerRadius = 8;
		alertTextField.textColor = [UIColor blackColor];
		alertTextField.textAlignment = UITextAlignmentCenter;
		alertTextField.font = [UIFont systemFontOfSize:14.0];
		alertTextField.backgroundColor = [UIColor whiteColor];

		/* no auto correction */
		alertTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		alertTextField.delegate = self;
	}

	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 45.0);
	[alert setTransform:myTransform];
	[alert addSubview:alertTextField];
	[alert show];
	[alertTextField becomeFirstResponder];
	[alertTextField release];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		for(UIView *subview in alertView.subviews)
		{
			if([subview isKindOfClass:[UITextField class]])
			{
				UITextField *textField = (UITextField *)subview;
				NSString *upperCaseUsername = [textField.text uppercaseString];
				if(!pendingFavorites)
				{
					self.pendingFavorites = [[NSMutableArray alloc] init];
				}
				[pendingFavorites addObject:upperCaseUsername];
				[super synchronousLoadPerson:upperCaseUsername];
			}
		}
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
	if( IsEmpty(people) )
	{
		[super synchronousLoadTwitterData];
	}
}

- (void)updateFavoritesWithPerson:(Person *)person
{
	NSString *upperCaseUsername = [person.screen_name uppercaseString];
	if([pendingFavorites containsObject:upperCaseUsername])
	{
		[userIdArray addObject:person.user_id];
		[FavoritesHelper saveFavorites:userIdArray];
		[pendingFavorites removeObject:upperCaseUsername];
	}
}

- (void)userInfoReceived:(NSDictionary *)userInfo forRequest:(NSString *)connectionIdentifier
{
	Person *person = [[Person alloc] initPersonWithInfo:userInfo];
	/* this person is not yet in the database */
	if([person isValid])
	{
		[super infoRecievedForPerson:person];
		[self updateFavoritesWithPerson:person];
	}
	[super didFinishLoadingPerson];
	[person release];
}

@end
