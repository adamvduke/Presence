//
//  StatusViewController.m
//  Presence
//
//  Created by Adam Duke on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PresenceContants.h"
#import "StatusViewController.h"
#import "TwitterHelper.h"

@implementation StatusViewController
@synthesize person;
@synthesize queue;
@synthesize spinner;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

// reload the table data and flash the scroll indicators when all of the data has been loaded
-(void) didFinishLoadingUpdates
{
	// if the spinner is active stop it
	if ([self.spinner isAnimating]) 
	{
		[self.spinner stopAnimating];
	}
	
	// stop the network indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
	
	// reload the table data and flash the scroll indicators
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

// synchronous method to fetch a list of updates
-(void) synchronousLoadUpdates
{	
	// attempt to limit the auto release footprint by creating an autorelease pool around the data load
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	// get the user's timeline
	NSArray *userTimeline = [TwitterHelper fetchTimelineForUsername:self.person.userName];
	
	// parse the individual statuses out of the timeline
	NSArray *statusArray = [TwitterHelper parseStatusUpdatesFromTimeline:userTimeline];
	
	// set the statusUpdates array on the person object so that they don't need to be fetched again
	self.person.statusUpdates = statusArray;
	
	//call the main thread to notify that the data has finished loading
	[self performSelectorOnMainThread:@selector(didFinishLoadingUpdates) withObject:nil waitUntilDone:NO];
	
	// release the NSAutoReleasePool
	[pool release];
}

// begin loading the updates asynchronously
- (void) beginLoadUpdates
{	
	// start the device's network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// start animating the spinner
	[self.spinner startAnimating];
	
	// create the NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadUpdates) object:nil];
	[self.queue addOperation:operation];
	[operation release];
}

// initialize with a UITableViewStyle and Person object
-(id)initWithStyle:(UITableViewStyle)style person:(Person *)aPerson
{
	if (self = [super initWithStyle:style]) 
	{				
		//this is the text displayed at the top
		NSString *statusViewTitle = NSLocalizedString(StatusViewTitleKey, @"");
		self.title = statusViewTitle;
		
		//set the person reference on the view
		self.person = aPerson;
		
		//Create the NSOperationQueue for threading data loading
		self.queue = [[NSOperationQueue alloc]init];
		
		//set the maxConcurrent operations to 1
		[self.queue setMaxConcurrentOperationCount:1];
		
		// initialize the UIActivityIndicatorView for this view controller
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self.spinner setCenter:self.view.center]; 
		[self.view addSubview:spinner];
		
		// set the right bar button for reloading the data with the Refresh style
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(beginLoadUpdates)];
		[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		[rightBarButton release];
	}
	return self;
}

// override viewWillAppear to load the data if it hasn't been already
-(void) viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	//if the person's status updates have not been loaded, load them
	if (self.person.statusUpdates == nil) 
	{
		[self beginLoadUpdates];
	}
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning 
{	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{	
	//There will be a title section and the statuses section
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	//section 1 will have 1 row, section 2 will have however many rows exist in the statusUpdates
	//array on the person object
	if(section == 0)
	{
		return 1;
	}
    return [self.person.statusUpdates count];
}

// Customize the content of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	// get the section of the selected cell, the title and status cell's have different styles
	// and the section number will determine the style
	NSUInteger section = indexPath.section;
	
	// declare the cell early so that either code path can initialize it
    UITableViewCell *cell;
	
	// if the section variable is zero, the requested cell is for the title section of the view
	if (section == 0) {
		
		// attempt to deque a reuseable cell with the TitleCellReuseIdentifier, if not available create one
		cell = [tableView dequeueReusableCellWithIdentifier:TitleCellReuseIdentifier];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleCellReuseIdentifier] autorelease];
		}
		
		// set only the text and image properties on the cell
		cell.textLabel.text = self.person.userName;
		cell.imageView.image = self.person.image;
	}
	
	// because there are only two sections, the else block will always create cells styled for statuses
	else 
	{
		// attempt to deque a reuseable cel with the TitleCellReuseIdentifier, if not available create one
		cell = [tableView dequeueReusableCellWithIdentifier:StatusCellReuseIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:StatusCellReuseIdentifier] autorelease];
		}
		
		// set the numberOfLines, font, and text properties on the cell's text label
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.text = [self.person.statusUpdates objectAtIndex:indexPath.row];
	}
	
	// set the selection style to None, these cells are not selectable
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

// return the custom height of the cell based on the string that will be displayed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	//if the index path represents the "Title cell" return the height of the user's image plus 15
	NSUInteger section = indexPath.section;
	if (section == 0) {
		CGSize imageSize = self.person.image.size;
		return imageSize.height + 15;
	}
	
	// if the index path represents a "Status cell" calculate the height based on the text
	NSString *someText = [person.statusUpdates objectAtIndex:indexPath.row];
	UIFont *font = [UIFont systemFontOfSize: 14 ]; 
	CGSize withinSize = CGSizeMake( 350, 150);
	CGSize size = [someText sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 35;
}

- (void)dealloc 
{
	[person release];
	[queue release];
	[spinner release];
    [super dealloc];
}
@end

