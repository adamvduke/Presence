//
//  PersonListViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "ListViewController.h"
#import "Person.h"
#import "PresenceContants.h"
#import "StatusViewController.h"
#import "TwitterHelper.h"


@implementation ListViewController

@synthesize personListName;
@synthesize people;
@synthesize queue;
@synthesize spinner;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// return YES for all interface orientations
	return YES;
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
		
		// if the spinner is active stop it
		if ([spinner isAnimating]) 
		{
			[spinner stopAnimating];
		}
		
		// stop the network indicator
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
		
		// flash the scroll indicators to show give the user an idea of how long the list is
		[self.tableView flashScrollIndicators];
	}
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
		[people addObject:person];
		[person release];
	}
	
	// call the main thread to notify that the person has finished loading
	[self performSelectorOnMainThread:@selector(didFinishLoadingPerson) withObject:nil waitUntilDone:NO];
}

// start to load a person object asynchronously
- (void) beginLoadPerson:(NSString *)userName
{
	//create an NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadPerson:) object:userName];
	[queue addOperation:operation];
	[operation release];
}

// synchronously get the usernames and call beginLoadPerson for each username
- (void)synchronousLoadTwitterData
{
	NSArray *userNames = nil;
	if (personListName != nil) {
		NSString *path = [[NSBundle mainBundle]pathForResource:personListName ofType:@"plist"];
		userNames = [NSArray arrayWithContentsOfFile:path];
	}
	else {
		// get the list of names that the user is following 
	}

	if (userNames != nil) {
		
		// start the device's network activity indicator
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		// start animating the spinner
		[spinner startAnimating];		
	}
	
	for (NSString *userName in userNames) 
	{
		[self beginLoadPerson:userName];
	}
}

// start to load data asynchronously so that the UI is not blocked
- (void)beginLoadingTwitterData
{

	//create the NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadTwitterData) object:nil];
	[queue addOperation:operation];
	[operation release];
}

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

-(id)initWithStyle:(UITableViewStyle)style listName:(NSString *)pListName
{
	
	if (self == [super initWithStyle:style]) {
		
		if (pListName != nil) {
			
			//the pListName if this controller is going to display a static list of people
			self.personListName = [NSString stringWithString:pListName];
		}
		
		//Create the NSOperationQueue for threading data loading
		queue = [[NSOperationQueue alloc]init];
		
		//set the maxConcurrent operations to 1
		[queue setMaxConcurrentOperationCount:1];
		
		//allocate the memory for the NSMutableArray of people on this ViewController
		people = [[NSMutableArray alloc]init];
		
		// initialize the UIActivityIndicatorView for this view controller
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[spinner setCenter:self.view.center]; 
		[self.view addSubview:spinner];
		
		// create a UIBarButtonItem for the right side using the Compose style, this will present the ComposeStatusViewController modally
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(presentUpdateStatusController)];
		[self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
		[rightBarButton release];
	}
	return self;
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
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Table view methods

// number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	//the main view only has 1 section
    return 1;
}


// Customize the number of rows per section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	//the size of the main view's section is the length of the array "people"
    return [people count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//if there is already a cell with the identifier that can be reused, get it
	//otherwise create a new cell
    static NSString *CellIdentifier = @"ListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	//get a person object out of the people array for the correct IndexPath
	//set the person's properties on the cell
	Person *person = [people objectAtIndex:indexPath.row];
	
	if (person.image == nil) 
	{
		//Initialize the UIImage for the person
		NSURL *imageUrl = [NSURL URLWithString:person.imageUrlString];
		NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
		UIImage *image = [[UIImage alloc] initWithData:imageData];
		person.image = image;
		[image release];
	}
	
	// set the image, text and accesory type on the cell
	cell.imageView.image = person.image;
    cell.textLabel.text = person.userName;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)dealloc 
{	
	// make sure to deallocate the people array and the operation queue
	[people release];
	[queue release];
	[spinner release];
	
	// always call the dealloc of the super class
    [super dealloc];
}
@end
