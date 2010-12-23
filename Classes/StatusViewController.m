/*  StatusViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 11/17/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "CredentialHelper.h"
#import "Person.h"
#import "PresenceAppDelegate.h"
#import "PresenceContants.h"
#import "StatusViewController.h"

@interface StatusViewController ()

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) SA_OAuthTwitterEngine *engine;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;

- (NSArray *)initStatusUpdatesFromTimeline:(NSArray *)userTimeline;

@end

@implementation StatusViewController

@synthesize spinner, engine, person, dataAccessHelper;

/* override shouldAutorotateToInterfaceOrientation to return YES for all interface orientations */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

/* reload the table data and flash the scroll indicators when all of the data has been loaded */
- (void)didFinishLoadingUpdates
{
	/* if the spinner is active stop it */
	if([self.spinner isAnimating])
	{
		[self.spinner stopAnimating];
	}

	/* stop the network indicator */
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	/* reload the table data and flash the scroll indicators */
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

- (NSArray *)initStatusUpdatesFromTimeline:(NSArray *)userTimeline
{
	NSMutableArray *statusUpdates = [[NSMutableArray alloc] init];
	for(NSDictionary *timelineEntry in userTimeline)
	{
		if([timelineEntry isKindOfClass:[NSDictionary class]])
		{
			Status *status = [[Status alloc] initWithTimelineEntry:timelineEntry];
			[statusUpdates addObject:status];
			[status release];
		}
	}
	return statusUpdates;
}

/* begin loading the updates asynchronously */
- (void)beginLoadUpdates:(BOOL)refresh
{
	if(!refresh && self.person && self.person.statusUpdates)
	{
		/* avoid doing any un-needed work */
		return;
	}

	/* start the device's network activity indicator */
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	/* start animating the spinner */
	[self.spinner startAnimating];

	/* get the user's timeline */
	[self.engine getUserTimelineFor:self.person.user_id sinceID:0 startingAtPage:1 count:20];
}

- (void)refresh
{
	[self beginLoadUpdates:YES];
}

/* initialize with a UITableViewStyle and Person object */
- (id)initWithPerson:(Person *)aPerson dataAccessHelper:(DataAccessHelper *)accessHelper
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		/* this is the text displayed at the top */
		self.title = NSLocalizedString(StatusViewTitleKey, @"");

		/* set the person reference on the view */
		self.person = aPerson;

		self.dataAccessHelper = accessHelper;

		/* initialize the UIActivityIndicatorView for this view controller */
		self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		[self.spinner setCenter:self.view.center];
		[self.view addSubview:spinner];

		/* set the right bar button for reloading the data with the Refresh style */
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
		                                                                                target:self
		                                                                                action:@selector(refresh)];
		[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		[rightBarButton release];
	}
	return self;
}

/* override viewWillAppear to load the data if it hasn't been already */
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

- (void)didReceiveMemoryWarning
{
	/* Releases the view if it doesn't have a superview. */
	[super didReceiveMemoryWarning];

	/* Release any cached data, images, etc that aren't in use. */
}

- (void)viewDidUnload
{
	/* Release any retained subviews of the main view.
	 * e.g. self.myOutlet = nil;
	 */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	/* There will be a title section and the statuses section */
	return 2;
}

/* Customize the number of rows in the table view. */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/* section 1 will have 1 row, section 2 will have however many rows exist in the
	 * statusUpdates array on the person object
	 */
	if(section == 0)
	{
		return 1;
	}
	return [self.person.statusUpdates count];
}

/* Customize the content of table view cells. */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	/* get the section of the selected cell, the title and status cell's have different styles
	 * and the section number will determine the style
	 */
	NSUInteger section = indexPath.section;

	/* declare the cell early so that either code path can initialize it */
	UITableViewCell *cell;
	/* if the section variable is zero, the requested cell is for the title section of the view
	 */
	if(section == 0)
	{
		/* attempt to deque a reuseable cell with the TitleCellReuseIdentifier, if not
		 *available create one */
		cell = [tableView dequeueReusableCellWithIdentifier:TitleCellReuseIdentifier];
		if(cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleCellReuseIdentifier] autorelease];
		}

		/* set only the text and image properties on the cell */
		cell.textLabel.text = self.person.screen_name;
		if(self.person.image)
		{
			cell.imageView.image = self.person.image;
		}
		else
		{
			cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
		}
	}

	/* because there are only two sections, the else block will always create cells styled for
	 *statuses */
	else
	{
		/* attempt to deque a reuseable cel with the TitleCellReuseIdentifier, if not
		 *available create one */
		cell = [tableView dequeueReusableCellWithIdentifier:StatusCellReuseIdentifier];
		if(cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StatusCellReuseIdentifier] autorelease];
		}

		/* set the numberOfLines, font, and text properties on the cell's text label */
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		Status *status = [self.person.statusUpdates objectAtIndex:indexPath.row];
		cell.textLabel.text = status.text;

		/* cell.detailTextLabel.text = status.createdDate; */
	}

	/* set the selection style to None, these cells are not selectable */
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

/* return the custom height of the cell based on the content that will be displayed */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	/* if the index path represents the "Title cell" return the height of the user's image plus
	**/
	NSUInteger section = indexPath.section;
	if(section == 0)
	{
		UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
		CGSize imageSize = cell.imageView.image.size;
		return imageSize.height + 15;
	}

	/* if the index path represents a "Status cell" calculate the height based on the text */
	Status *status = [person.statusUpdates objectAtIndex:indexPath.row];
	NSString *someText = status.text;
	UIFont *font = [UIFont systemFontOfSize:14 ];
	CGSize withinSize = CGSizeMake( 350, 150);
	CGSize size = [someText sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 35;
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
	[self didFinishLoadingUpdates];
}

- (void)authSucceededForEngine
{
	[self beginLoadUpdates:NO];
}

/* These delegate methods are called after all results are parsed from the connection. If
 * the deliveryOption is configured for MGTwitterEngineDeliveryAllResults (the default), a
 * collection of all results is also returned.
 */
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
	/* parse the individual statuses out of the timeline */
	NSArray *statusArray = [self initStatusUpdatesFromTimeline:statuses];

	/* set the statusUpdates array on the person object so that they don't need to be fetched
	 * again */
	self.person.statusUpdates = statusArray;

	[self didFinishLoadingUpdates];
}

- (void)dealloc
{
	[person release];
	[spinner release];
	[super dealloc];
}

@end