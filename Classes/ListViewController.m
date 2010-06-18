//
//  PersonListViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IconDownloader.h"
#import "ListViewController.h"
#import "Person.h"
#import "PresenceContants.h"
#import "StatusViewController.h"
#import "TwitterHelper.h"

#define kCustomRowCount 7

@interface ListViewController ()

- (void) startIconDownload:(Person *)aPerson forIndexPath:(NSIndexPath *)indexPath;
- (void) beginLoadingTwitterData;
- (void) synchronousLoadTwitterData;
- (void) beginLoadPerson:(NSString *)userName;
- (void) synchronousLoadPerson:(NSString *)userName;
- (void) didFinishLoadingPerson;

@end

@implementation ListViewController

@synthesize usernameArray;
@synthesize people;
@synthesize imageDownloadsInProgress;
@synthesize queue;

- (void)dealloc 
{	
	// make sure to deallocate the people array and the operation queue
	[people release];
	[queue release];
	[imageDownloadsInProgress release];
	
	// always call the dealloc of the super class
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// return YES for all interface orientations
	return YES;
}

- (void)viewDidLoad
{
	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

// override viewWillAppear to begin the data load
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// if the array of people is empty, start the activity indicators and begin loading data
	if ([people count] == 0) 
	{
		//begin loading data from twitter
		[self beginLoadingTwitterData];
	}
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads performSelector:@selector(cancelDownload)];
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Data loading
// start to load data asynchronously so that the UI is not blocked
- (void)beginLoadingTwitterData
{
	//create the NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadTwitterData) object:nil];
	[self.queue addOperation:operation];
	[operation release];
}

// synchronously get the usernames and call beginLoadPerson for each username
- (void)synchronousLoadTwitterData
{
	if (self.usernameArray != nil) {
		
		// start the device's network activity indicator
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	
	for (NSString *username in usernameArray) 
	{
		[self beginLoadPerson:username];
	}
}

// start to load a person object asynchronously
- (void) beginLoadPerson:(NSString *)userName
{
	//create an NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadPerson:) object:userName];
	[self.queue addOperation:operation];
	[operation release];
}

// synchronously fetch data, initialize a person object, and add it to the list of people
// call the main thread when finished
-(void) synchronousLoadPerson:(NSString *)userName
{
	// get the user's information from Twitter
	NSDictionary *userInfo = [TwitterHelper fetchInfoForUsername:userName];
	if (userInfo != nil) 
	{
		Person *person = [[Person alloc]initPersonWithInfo:userInfo userName:userName];
		if (person != nil) {
			[self.people addObject:person];
			[person release];
		}
	}
	
	// call the main thread to notify that the person has finished loading
	[self performSelectorOnMainThread:@selector(didFinishLoadingPerson) withObject:nil waitUntilDone:NO];
}

// called by synchronousLoadPerson when the load has finished
-(void) didFinishLoadingPerson
{
	// after each person has finished loading, reload the table's data
	[self.tableView reloadData];
	
	// if this is the last operation in the queue
	NSArray *operations = [queue operations];
	if ([operations count] <= 1) 
	{		
		// stop the network indicator
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
		
		// flash the scroll indicators to show give the user an idea of how long the list is
		[self.tableView flashScrollIndicators];
	}
}

#pragma mark -
#pragma mark Modal ComposeStatusViewController
// show a modal view controller that will allow a user to compose a twitter status
-(void)presentUpdateStatusController
{
	ComposeStatusViewController *statusViewController = [[ComposeStatusViewController alloc] initWithNibName:ComposeStatusViewControllerNibName bundle:[NSBundle mainBundle]];
	statusViewController.delegate = self;
	[self.navigationController presentModalViewController:statusViewController animated:YES];
	[statusViewController release];
}

// ComposeStatusViewControllerDelegate protocol
-(void)didFinishComposing:(ComposeStatusViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark custom init method
-(id)initWithStyle:(UITableViewStyle)style usernameArray:(NSArray *)usernames
{
	
	if (self == [super initWithStyle:style]) {
		
		// set the list of users to load
		self.usernameArray = usernames;
		
		//Create the NSOperationQueue for threading data loading
		self.queue = [[NSOperationQueue alloc]init];
		
		//set the maxConcurrent operations to 1
		[self.queue setMaxConcurrentOperationCount:1];
		
		//allocate the memory for the NSMutableArray of people on this ViewController
		self.people = [[NSMutableArray alloc]init];
		
		// create a UIBarButtonItem for the right side using the Compose style, this will present the ComposeStatusViewController modally
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(presentUpdateStatusController)];
		[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		[rightBarButton release];
	}
	return self;
}

#pragma mark -
#pragma mark Table view methods

// Customize the number of rows per section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	int count = [self.people count];
	
	// if there's no data yet, return enough rows to fill the screen
    if (count == 0)
	{
        return kCustomRowCount;
    }
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//if there is already a cell with the identifier that can be reused, get it
	//otherwise create a new cell
    static NSString *CellIdentifier = @"ListCell";
	static NSString *PlaceHolderIdentifier = @"PlaceHolder";
	
	// add a placeholder cell while waiting on table data
    int nodeCount = [self.people count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceHolderIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PlaceHolderIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
		
		cell.detailTextLabel.text = @"Loading…";
		
		return cell;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
	// Leave cells empty if there's no data yet
	if (nodeCount > 0)
	{
		// Set up the cell...
		Person *person = [self.people objectAtIndex:indexPath.row];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = person.userName;
		
		// TODO: add field to person for the detail text label
		//cell.detailTextLabel.text = appRecord.artist;
		
		// Only load cached images; defer new downloads until scrolling ends
		if (!person.image)
		{
			if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
			{
				[self startIconDownload:person forIndexPath:indexPath];
			}
			// if a download is deferred or in progress, return a placeholder image
			cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
		}
		else
		{
			cell.imageView.image = person.image;
		}
	}
	return cell;
}

// override didSelectRowAtIndexPath to push a StatusViewController onto the navigation stack when a row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	// Create and push another view controller.
	// get the correct person out of the people array and initialize the status view controller for that person
	Person *person = [people objectAtIndex:indexPath.row];
	StatusViewController *statusViewController = [[StatusViewController alloc] initWithStyle:UITableViewStyleGrouped person:person];
	
	// push the new view controller onto the navigation stack
	[self.navigationController pushViewController:statusViewController animated:YES];
	[statusViewController release];
}
#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(Person *)aPerson forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
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

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.people count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Person *person = [self.people objectAtIndex:indexPath.row];
            
            if (!person.image) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:person forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.person.image;
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end
