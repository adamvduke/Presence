//
//  StatusViewController.m
//  Presence
//
//  Created by Adam Duke on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StatusViewController.h"
#import "TwitterHelper.h"

@implementation StatusViewController
@synthesize person;
@synthesize queue;

-(void) didFinishLoadingUpdates{

	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

-(void) synchronousLoadUpdates{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSArray *userTimeline = [TwitterHelper fetchTimelineForUsername:person.userName];
	NSArray *statusArray = [TwitterHelper parseStatusUpdatesFromTimeline:userTimeline];
	person.statusUpdates = statusArray;
	
	//call the main thread to notify that the data has finished loading
	[self performSelectorOnMainThread:@selector(didFinishLoadingUpdates) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void) beginLoadUpdates{
	
	//create the NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadUpdates) object:nil];
	[queue addOperation:operation];
	[operation release];
}

-(id)initWithStyle:(UITableViewStyle)style person:(Person *)aPerson{

	if (self = [super initWithStyle:style]) {
				
		//set the right bar button for reloading the data
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(beginLoadUpdates)];
		[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		[rightBarButton release];

		//set the title of the view to "Tweets"
		//this is the text displayed at the top
		self.title = @"Tweets";
		
		//set the person reference on the view
		self.person = aPerson;
		[aPerson retain];
		
		//Create the NSOperationQueue for threading data loading
		queue = [[NSOperationQueue alloc]init];
		
		//set the maxConcurrent operations to 1
		[queue setMaxConcurrentOperationCount:1];
	}
	return self;
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	//if the person's status updates have not been loaded, load them
	if (person.statusUpdates == nil) {
		[self beginLoadUpdates];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	//There will be a title section and the statuses section
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	//section 1 will have 1 row, section 2 will have however many rows exist in the statusUpdates
	//array on the person object
	if(section == 0)
	{
		return 1;
	}
    return [person.statusUpdates count];
}

// Customize the content of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *TitleCell = @"TitleCell";
	static NSString *StatusCell = @"StatusCell";
	
	NSUInteger section = indexPath.section;
    UITableViewCell *cell;
	
	
	//TODO: Document this method better
	if (section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:TitleCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleCell] autorelease];
		}
		cell.textLabel.text = person.userName;
		cell.imageView.image = person.image;
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:StatusCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:StatusCell] autorelease];
		}
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.text = [person.statusUpdates objectAtIndex:indexPath.row];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return cell;
}

// return the custom height of the cell based on the string that will be displayed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	//if the index path represents the "Title cell" return the height of the user's image plus 20
	NSUInteger section = indexPath.section;
	if (section == 0) {
		CGSize imageSize = person.image.size;
		return imageSize.height + 15;
	}
	
	// if the index path represents a "Status cell" calculate the height based on the text
	NSString *someText = [person.statusUpdates objectAtIndex:indexPath.row];
	UIFont *font = [UIFont systemFontOfSize: 14 ]; 
	CGSize withinSize = CGSizeMake( 350, 150);
	CGSize size = [someText sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 35;
}

- (void)dealloc {
	[person release];
	[queue dealloc];
    [super dealloc];
}
@end

