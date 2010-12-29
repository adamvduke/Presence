/*  PersonListViewController.m
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
#import "Person.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"
#import "StatusViewController.h"
#import "ValidationHelper.h"

#define kCustomRowHeight 48  /* height of each row */
#define kThreadBatchCount 5 /* number of rows to create before re-drawing the table view */

@interface ListViewController ()

- (void)startIconDownload:(Person *)aPerson forIndexPath:(NSIndexPath *)indexPath;
- (void)synchronousLoadTwitterData;

@end

@implementation ListViewController

@synthesize engine, composeBarButton, userIdArray, people;
@synthesize imageDownloadsInProgress, finishedThreads, dataAccessHelper;

#pragma mark -
#pragma mark custom init method

- (id)initWithUserIdArray:(NSMutableArray *)userIds
{
	if(self == [super initWithStyle:UITableViewStylePlain])
	{
		/* set the list of users to load */
		self.userIdArray = userIds;

		/* allocate the memory for the NSMutableArray of people on this ViewController */
		self.people = [[NSMutableArray alloc] init];

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
	[self.people removeAllObjects];
	[self synchronousLoadTwitterData];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
	[composeBarButton release];
	[userIdArray release];
	[people release];
	[imageDownloadsInProgress release];

	/* always call the dealloc of the super class */
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
	/* for each person, determine if the person is visible
	 * if not, set the person's statusUpdate and image properties to nil
	 */
	for(int i = 0; i < [people count]; i++)
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
			Person *person = [people objectAtIndex:i];
			if(person)
			{
				person.statusUpdates = nil;
				person.image = nil;
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

/* synchronously get the usernames and call beginLoadPerson for each username */
- (void)synchronousLoadTwitterData
{
	if( !IsEmpty(self.userIdArray) )
	{
		/* start the device's network activity indicator */
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		for(NSString *user_id in self.userIdArray)
		{
			[self synchronousLoadPerson:user_id];
		}
	}
}

/* synchronously fetch data, initialize a person object, and add it to the list of people
 * call the main thread when finished
 */
- (void)synchronousLoadPerson:(NSString *)user_id
{
	Person *person = [dataAccessHelper initPersonByUserId:user_id];
	if(![person isValid])
	{
		[person release];
		person = nil;

		/* get the user's information from Twitter */
		[self.engine getUserInformationFor:user_id];
	}
	else
	{
		[self.people addObject:person];
		[person release];
		[self didFinishLoadingPerson];
	}
}

- (BOOL)dataLoadComplete
{
	return [self.userIdArray count] == [self.people count];
}

/* called by synchronousLoadPerson when the load has finished */
- (void)didFinishLoadingPerson
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
	int count = [self.people count];
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

	int peopleCount = [self.people count];
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
		Person *person = [self.people objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = person.screen_name;
		/* Only load cached images; defer new downloads until scrolling ends */
		if(!person.image)
		{
			/* first check the database */
			UIImage *anImage = [dataAccessHelper initImageForUserId:person.user_id];
			if(!anImage)
			{
				if(self.tableView.dragging == NO && self.tableView.decelerating == NO)
				{
					/* if there was no image in the database
					 * and the tableview is not dragging or decelerating
					 * start to download the image
					 */
					[self startIconDownload:person forIndexPath:indexPath];
				}

				/* if a download is deferred or in progress, return a placeholder
				 * image */
				cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
			}
			else
			{
				person.image = anImage;
				[anImage release];
				cell.imageView.image = person.image;
			}
		}
		else
		{
			cell.imageView.image = person.image;
		}
	}
	return cell;
}

/* override didSelectRowAtIndexPath to push a StatusViewController onto the navigation stack when a
 * row is selected */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!IsEmpty(self.people) > 0)
	{
		/* get the correct person out of the people array and initialize the status view
		 * controller for that person */
		Person *person = [people objectAtIndex:indexPath.row];
		StatusViewController *statusViewController = [[StatusViewController alloc] initWithPerson:person dataAccessHelper:dataAccessHelper];

		/* push the new view controller onto the navigation stack */
		[self.navigationController pushViewController:statusViewController animated:YES];
		[statusViewController release];
	}
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(Person *)aPerson forIndexPath:(NSIndexPath *)indexPath
{
	/* check for a download in progress for the indexPath
	 * if there isn't one, create one and start the download
	 */
	IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
	if(iconDownloader == nil)
	{
		iconDownloader = [[IconDownloader alloc] init];
		iconDownloader.person = aPerson;
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
			Person *person = [self.people objectAtIndex:indexPath.row];
			if(!person.image)
			{
				/* avoid the app icon download if the app already has an icon */
				[self startIconDownload:person forIndexPath:indexPath];
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
		Person *person = iconDownloader.person;
		[dataAccessHelper saveOrUpdatePerson:person];
		cell.imageView.image = person.image;
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
	if( IsEmpty(people) )
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

- (void)infoRecievedForPerson:(Person *)person
{
	[dataAccessHelper saveOrUpdatePerson:person];
	[self.people addObject:person];
}

- (void)userInfoReceived:(NSDictionary *)userInfo forRequest:(NSString *)connectionIdentifier
{
	Person *person = [[Person alloc] initPersonWithInfo:userInfo];
	/* this person is not yet in the database */
	if([person isValid])
	{
		[self infoRecievedForPerson:person];
	}
	[self didFinishLoadingPerson];
	[person release];
}

@end