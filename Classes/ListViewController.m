/*  ListViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "FavoritesHelper.h"
#import "ListViewController.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"
#import "StatusViewController.h"
#import "User.h"
#import "ValidationHelper.h"

#define kCustomRowHeight 48  /* height of each row */
#define kThreadBatchCount 5 /* number of rows to create before re-drawing the table view */

@interface ListViewController ()

- (void)startIconDownload:(User *)aUser forIndexPath:(NSIndexPath *)indexPath;
- (void)synchronousLoadTwitterData;

@end

@implementation ListViewController

@synthesize engine, composeBarButton, userIdArray, users;
@synthesize imageDownloadsInProgress, finishedThreads, dataAccessHelper;

#pragma mark -
#pragma mark custom init method

- (id)initWithUserIdArray:(NSMutableArray *)userIds
{
	if(self = [super initWithStyle:UITableViewStylePlain])
	{
		/* set the list of users to load */
		self.userIdArray = userIds;

		/* allocate the memory for the NSMutableArray of people on this ViewController */
		self.users = [[NSMutableArray alloc] init];

		/* create a UIBarButtonItem for the right side using the Compose style, this will
		 * present the ComposeStatusViewController modally */
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
		                                                                                target:self
		                                                                                action:@selector(presentUpdateStatusController)];
		[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		[rightBarButton release];
	}
	return self;
}

- (void)setUserIdArray:(NSMutableArray *)newIdArray
{
	[userIdArray autorelease];
	userIdArray = [newIdArray retain];
	[self.users removeAllObjects];
	[self synchronousLoadTwitterData];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
	[engine release];
	[composeBarButton release];
	[userIdArray release];
	[users release];
	[imageDownloadsInProgress release];
	[dataAccessHelper release];
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	/* return YES for all interface orientations */
	return YES;
}

- (void)viewDidLoad
{
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

/* override viewWillAppear to begin the data load */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if(![self.engine isAuthorized])
	{
		PresenceAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		self.engine = [appDelegate getEngineForDelegate:self];
	}
	if([self.engine isAuthorized])
	{
		[self authSucceededForEngine];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	/* Releases the view if it doesn't have a superview. */
	[super didReceiveMemoryWarning];

	/* terminate all pending download connections */
	NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
	[allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];

	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	/* for each user, determine if the user is visible
	 * if not, set the user's statusUpdate and image properties to nil
	 */
	for(int i = 0; i < [users count]; i++)
	{
		BOOL visible = NO;
		for(NSIndexPath *path in visiblePaths)
		{
			if(path.row == i)
			{
				visible = YES;
				break;
			}
		}
		if(!visible)
		{
			User *user = [users objectAtIndex:i];
			if(user)
			{
				user.statusUpdates = nil;
				user.image = nil;
			}
		}
	}
}

- (void)viewDidUnload
{
	/* Release any retained subviews of the main view.
	 * e.g. self.myOutlet = nil;
	 */
}

#pragma mark -
#pragma mark Data loading

/* synchronously get the usernames and call beginLoadUser for each username */
- (void)synchronousLoadTwitterData
{
	if( !IsEmpty(self.userIdArray) )
	{
		/* start the device's network activity indicator */
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		for(NSString *user_id in self.userIdArray)
		{
			[self synchronousLoadUser:user_id];
		}
	}
}

/* synchronously fetch data, initialize a user object, and add it to the list of people
 * call the main thread when finished
 */
- (void)synchronousLoadUser:(NSString *)user_id
{
	User *user = [dataAccessHelper initUserByUserId:user_id];
	if(![user isValid])
	{
		[user release];
		user = nil;

		/* get the user's information from Twitter */
		[self.engine getUserInformationFor:user_id];
	}
	else
	{
		[self.users addObject:user];
		[user release];
		[self didFinishLoadingUser];
	}
}

- (BOOL)dataLoadComplete
{
	return [self.userIdArray count] == [self.users count];
}

/* called by synchronousLoadUser when the load has finished */
- (void)didFinishLoadingUser
{
	/* in order to save redrawing the UI after every load, redraw after ever kThreadBatchCount
	 * loads or redraw in the case that the queue is on it's last operation
	 */
	self.finishedThreads++;
	if(self.finishedThreads == kThreadBatchCount || [self dataLoadComplete])
	{
		self.finishedThreads = 0;

		/* reload the table's data */
		[self.tableView reloadData];
		if([self dataLoadComplete])
		{
			/* stop the network indicator */
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

			/* flash the scroll indicators to show give the user an idea of how long the
			 * list is */
			[self.tableView flashScrollIndicators];
		}
	}
}

#pragma mark -
#pragma mark Modal ComposeStatusViewController

/* show a modal view controller that will allow a user to compose a twitter status */
- (void)presentUpdateStatusController
{
	ComposeStatusViewController *statusViewController = [[ComposeStatusViewController alloc] initWithNibName:ComposeStatusViewControllerNibName
	                                                                                                  bundle:[NSBundle mainBundle]];
	statusViewController.delegate = self;
	[self.navigationController presentModalViewController:statusViewController animated:YES];
	[statusViewController release];
}

/* ComposeStatusViewControllerDelegate protocol */
- (void)didFinishComposing:(ComposeStatusViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view methods

/* Customize the number of rows per section */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [self.users count];
	return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCustomRowHeight;
}

- (UITableViewCell *)placeHolderCellForTableView:(UITableView *)tableView
{
	static NSString *PlaceHolderIdentifier = @"PlaceHolder";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceHolderIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PlaceHolderIdentifier] autorelease];
		cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	cell.detailTextLabel.text = NSLocalizedString(LoadingKey, @"");
	return cell;
}

/* Customize the appearance of table view cells. */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ListCell";

	int peopleCount = [self.users count];
	int idCount = [self.userIdArray count];
	/* if this is the first row and there are no people to display yet
	 * but there should be, display a cell that indicates data is loading
	 */
	if(peopleCount == 0 && indexPath.row == 0 && idCount > 0)
	{
		return [self placeHolderCellForTableView:tableView];
	}

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	/* Leave cells empty if there's no data yet */
	if(peopleCount > 0 && indexPath.row < peopleCount)
	{
		/* Set up the cell... */
		User *user = [self.users objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = user.screen_name;
		/* Only load cached images; defer new downloads until scrolling ends */
		if(!user.image)
		{
			/* first check the database */
			UIImage *anImage = [dataAccessHelper initImageForUserId:user.user_id];
			if(!anImage)
			{
				if(self.tableView.dragging == NO && self.tableView.decelerating == NO)
				{
					/* if there was no image in the database
					 * and the tableview is not dragging or decelerating
					 * start to download the image
					 */
					[self startIconDownload:user forIndexPath:indexPath];
				}

				/* if a download is deferred or in progress, return a placeholder
				 * image */
				cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
			}
			else
			{
				user.image = anImage;
				[anImage release];
				cell.imageView.image = user.image;
			}
		}
		else
		{
			cell.imageView.image = user.image;
		}
	}
	return cell;
}

/* override didSelectRowAtIndexPath to push a StatusViewController onto the navigation stack when a
 * row is selected */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!IsEmpty(self.users) > 0)
	{
		/* get the correct user out of the people array and initialize the status view
		 * controller for that user */
		User *user = [users objectAtIndex:indexPath.row];
		StatusViewController *statusViewController = [[StatusViewController alloc] initWithUser:user dataAccessHelper:dataAccessHelper];

		/* push the new view controller onto the navigation stack */
		[self.navigationController pushViewController:statusViewController animated:YES];
		[statusViewController release];
	}
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(User *)aUser forIndexPath:(NSIndexPath *)indexPath
{
	/* check for a download in progress for the indexPath
	 * if there isn't one, create one and start the download
	 */
	IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
	if(iconDownloader == nil)
	{
		iconDownloader = [[IconDownloader alloc] init];
		iconDownloader.user = aUser;
		iconDownloader.indexPathInTableView = indexPath;
		iconDownloader.delegate = self;
		[imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
		[iconDownloader startDownload];
		[iconDownloader release];
	}
}

/* this method is used in case the user scrolled into a set of cells that don't have their app icons
 * yet */
- (void)loadImagesForOnscreenRows
{
	if(!IsEmpty(self.userIdArray) > 0)
	{
		NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
		for(NSIndexPath *indexPath in visiblePaths)
		{
			User *user = [self.users objectAtIndex:indexPath.row];
			if(!user.image)
			{
				/* avoid the app icon download if the app already has an icon */
				[self startIconDownload:user forIndexPath:indexPath];
			}
		}
	}
}

/* called by our ImageDownloader when an icon is ready to be displayed */
- (void)imageDidLoad:(NSIndexPath *)indexPath
{
	IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
	if(iconDownloader != nil)
	{
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];

		/* Display the newly loaded image */
		User *user = iconDownloader.user;
		[dataAccessHelper saveOrUpdateUser:user];
		cell.imageView.image = user.image;
	}
	[imageDownloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

/* Load images for all onscreen rows when scrolling is finished */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(!decelerate)
	{
		[self loadImagesForOnscreenRows];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self loadImagesForOnscreenRows];
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
	return [CredentialHelper retrieveAuthData];
}

- (void)authSucceededForEngine
{
	if( IsEmpty(users) )
	{
		[self synchronousLoadTwitterData];
	}
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
	NSLog(@"Request succeeded %@, response pending.", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Request failed %@, with error %@.", connectionIdentifier, [error localizedDescription]);
}

- (void)infoRecievedForUser:(User *)user
{
	[dataAccessHelper saveOrUpdateUser:user];
	[self.users addObject:user];
}

- (void)userInfoReceived:(NSDictionary *)userInfo forRequest:(NSString *)connectionIdentifier
{
	User *user = [[User alloc] initWithInfo:userInfo];
	/* this user is not yet in the database */
	if([user isValid])
	{
		[self infoRecievedForUser:user];
	}
	[self didFinishLoadingUser];
	[user release];
}

@end