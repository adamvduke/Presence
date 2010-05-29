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
@synthesize statusUpdates;
@synthesize queue;

-(NSArray *)parseStatusUpdatesFromTimeline:(NSArray *)userTimeline{
	
	NSMutableArray *temp = [[NSMutableArray alloc]init];
	for (NSDictionary *timelineEntry in userTimeline) {
		NSString *formatString = [NSString stringWithString:[timelineEntry objectForKey:@"text"]];
		[temp addObject:formatString];
	}
	NSArray *returnArray = [NSArray arrayWithArray:temp];
	[temp release];
	
	return returnArray;
}

-(void) didFinishLoadingUpdates{

	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

-(void) synchronousLoadUpdates{
	
	NSArray *userTimeline = [TwitterHelper fetchTimelineForUsername:person.userName];
	NSArray *statusArray = [self parseStatusUpdatesFromTimeline:userTimeline];
	self.statusUpdates = statusArray;
	
	//call the main thread to notify that the data has finished loading
	[self performSelectorOnMainThread:@selector(didFinishLoadingUpdates) withObject:nil waitUntilDone:NO];
}

- (void) beginLoadUpdates{
	
	//create the NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadUpdates) object:nil];
	[queue addOperation:operation];
	[operation release];
}

-(id)initWithStyle:(UITableViewStyle)style person:(Person *)aPerson{

	if (self = [super initWithStyle:style]) {
		
		//set the title of the view to "Tweets"
		//this is the text displayed at the top
		self.title = @"Tweets";
		
		//set the person reference on the view
		self.person = aPerson;
		
		//Create the NSOperationQueue for threading data loading
		queue = [[NSOperationQueue alloc]init];
		
		//set the maxConcurrent operations to 1
		[queue setMaxConcurrentOperationCount:1];
	}
	return self;
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self beginLoadUpdates];
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
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if(section > 0)
	{
		return [statusUpdates count];
	}
    return 1;
}

// Customize the content of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *TitleCell = @"TitleCell";
	static NSString *StatusCell = @"StatusCell";
	
	NSUInteger section = indexPath.section;
    UITableViewCell *cell;
	
	if (section > 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:StatusCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:StatusCell] autorelease];
		}
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.text = [statusUpdates objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:TitleCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:TitleCell] autorelease];
		}
		cell.textLabel.text = person.userName;
		cell.imageView.image = person.image;
	}
	return cell;
}

// return the custom height of the cell based on the string that will be displayed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSString *someText = [statusUpdates objectAtIndex:indexPath.row];
	UIFont *font = [UIFont systemFontOfSize: 14 ]; 
	CGSize withinSize = CGSizeMake( 350, 1000);
	CGSize size = [someText sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 45; 
}

- (void)dealloc {
	[queue dealloc];
    [super dealloc];
}
@end

