/*  StatusViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 11/17/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "ADEngineBlock.h"
#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"
#import "Status.h"
#import "StatusViewController.h"
#import "User.h"

@interface StatusViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) DataAccessHelper *dataAccessHelper;

- (NSArray *)statusUpdatesFromTimeline:(NSArray *)userTimeline;

@end

@implementation StatusViewController

@synthesize engineBlock, spinner, user, dataAccessHelper;

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

- (NSArray *)statusUpdatesFromTimeline:(NSArray *)userTimeline
{
	NSMutableArray *statusUpdates = [[NSMutableArray alloc] init];
	for(NSDictionary *timelineEntry in userTimeline)
	{
		if([timelineEntry isKindOfClass:[NSDictionary class]])
		{
			Status *status = [[Status alloc] initWithTimelineEntry:timelineEntry];
			[statusUpdates addObject:status];
		}
	}
	return statusUpdates;
}

/* begin loading the updates asynchronously */
- (void)beginLoadUpdates:(BOOL)refresh
{
	if(!refresh && self.user && self.user.statusUpdates)
	{
		/* avoid doing any un-needed work */
		return;
	}

	/* start the device's network activity indicator */
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	/* start animating the spinner */
	[self.spinner startAnimating];

	/* TODO: get the user's timeline */
    /* parse the individual statuses out of the timeline */
    
    [self.engineBlock userTimelineForScreenname:self.user.screen_name userId:0 sinceId:0 maxId:0 count:0 page:0 trimUser:YES includeRts:YES includeEntities:NO withHandler:^(NSArray *result, NSError *error)
    {
        NSArray *statusArray = [self statusUpdatesFromTimeline:result];
        
        /* set the statusUpdates array on the user object so that they don't need to be fetched
         * again */
        self.user.statusUpdates = statusArray;
        
        [self didFinishLoadingUpdates];
    }];
}

- (void)refresh
{
	[self beginLoadUpdates:YES];
}

/* initialize with a UITableViewStyle and user object */
- (id)initWithUser:(User *)aUser dataAccessHelper:(DataAccessHelper *)accessHelper engine:(ADEngineBlock *)engine
{
	if(self = [super initWithStyle:UITableViewStyleGrouped])
	{
		/* this is the text displayed at the top */
		self.title = NSLocalizedString(StatusViewTitleKey, @"");

		/* set the user reference on the view */
		self.user = aUser;

		self.dataAccessHelper = accessHelper;
        self.engineBlock = engine;

		/* initialize the UIActivityIndicatorView for this view controller */
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self.spinner setCenter:self.view.center];
		[self.view addSubview:spinner];

		/* set the right bar button for reloading the data with the Refresh style */
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
		                                                                                target:self
		                                                                                action:@selector(refresh)];
		[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
	}
	return self;
}

/* override viewWillAppear to load the data if it hasn't been already */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [self beginLoadUpdates:NO];
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
	 * statusUpdates array on the user object
	 */
	if(section == 0)
	{
		return 1;
	}
	return [self.user.statusUpdates count];
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
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellReuseIdentifier];
		}

		/* set only the text and image properties on the cell */
		cell.textLabel.text = self.user.screen_name;
		if(self.user.image)
		{
			cell.imageView.image = self.user.image;
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
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StatusCellReuseIdentifier];
		}

		/* set the numberOfLines, font, and text properties on the cell's text label */
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		Status *status = [self.user.statusUpdates objectAtIndex:indexPath.row];
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
	Status *status = [user.statusUpdates objectAtIndex:indexPath.row];
	NSString *someText = status.text;
	UIFont *font = [UIFont systemFontOfSize:14 ];
	CGSize withinSize = CGSizeMake( 350, 150);
	CGSize size = [someText sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 35;
}

- (void)authSucceededForEngine
{
	[self beginLoadUpdates:NO];
}

- (void)deauthorizeEngine
{
	/* TODO: clear the access token */
}

/* These delegate methods are called after all results are parsed from the connection. If
 * the deliveryOption is configured for MGTwitterEngineDeliveryAllResults (the default), a
 * collection of all results is also returned.
 */
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
	/* parse the individual statuses out of the timeline */
	NSArray *statusArray = [self statusUpdatesFromTimeline:statuses];

	/* set the statusUpdates array on the user object so that they don't need to be fetched
	 * again */
	self.user.statusUpdates = statusArray;

	[self didFinishLoadingUpdates];
}


@end