//
//  PersonListViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "Person.h"
#import "TwitterHelper.h"
#import "StatusViewController.h"

@implementation ListViewController

@synthesize people;
@synthesize queue;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return  (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//Create a Person object from the NSDictionary of userInfo and a userName
- (Person *) initPersonWithInfo:(NSDictionary *)userInfo userName:(NSString *)userName {
	
	//Keys in the dictionary for the url string and display name
	NSString *imageUrlString = [userInfo valueForKey:@"profile_image_url"];
	NSString *displayName = [userInfo valueForKey:@"screen_name"];
	
	//Initialize the UIImage for the person
	NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
	NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
	UIImage *image = [[UIImage alloc] initWithData:imageData];
	
	//Create the person object and return it
	Person *person = [[Person alloc]init];
	person.userName = userName;
	person.displayName = displayName;
	person.imageUrlString = imageUrlString;
	person.image = image;
	[image release];
	return person;
}

- (id)initWithStyle:(UITableViewStyle)style {
		
	if (self = [super initWithStyle:style]){
		
		//Create the NSOperationQueue for threading data loading
		queue = [[NSOperationQueue alloc]init];
		
		//set the maxConcurrent operations to 1
		[queue setMaxConcurrentOperationCount:1];

		//allocate the memory for the NSMutableArray of people on this ViewController
		people = [[NSMutableArray alloc]init];
	}
	return self;
}

-(void) didFinishLoadingPerson{
	
	//after each person has finished loading, reload the table's data
	[self.tableView reloadData];
	
	//if this is the last operation in the queue, flash the scroll indicators
	NSArray *operations = [queue operations];
	if ([operations count] == 1) {
		[self.tableView flashScrollIndicators];
	}
}

-(void) synchronousLoadPerson:(NSString *)userName{
	
	//Get the user's information from Twitter
	NSDictionary *userInfo = [TwitterHelper fetchInfoForUsername:userName];
	if (userInfo != nil) {
		Person *person = [self initPersonWithInfo:userInfo userName:userName];
		[people addObject:person];
		[person release];
	}
	
	//call the main thread to notify that the person has finished loading
	[self performSelectorOnMainThread:@selector(didFinishLoadingPerson) withObject:nil waitUntilDone:NO];
}

- (void) beginLoadPerson:(NSString *)userName{
	
	//create the NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadPerson:) object:userName];
	[queue addOperation:operation];
	[operation release];
}

- (void)synchronousLoadTwitterData{
	
	//read the user names from the TwitterUsers plist and begin a load operation for each person
	NSString *path = [[NSBundle mainBundle]pathForResource:@"TwitterUsers" ofType:@"plist"];
	NSArray *userNames = [NSArray arrayWithContentsOfFile:path];
	for (NSString *userName in userNames) {
		[self beginLoadPerson:userName];
	}
}

- (void)beginLoadingTwitterData{

	//create the NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadTwitterData) object:nil];
	[queue addOperation:operation];
	[operation release];
}

- (void)viewWillAppear:(BOOL)animated{

	[super viewWillAppear:animated];
	
	//begin loading data from twitter
	[self beginLoadingTwitterData];
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

#pragma mark Table view methods

// number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	//the main view only has 1 section
    return 1;
}


// Customize the number of rows per section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	//the size of the main view's section is the length of the array "people"
    return [people count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//if there is already a cell with the identifier that can be reused, get it
	//otherwise create a new cell
    static NSString *CellIdentifier = @"ListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	//get a person object out of the people array for the correct IndexPath
	//set the person's properties on the cell
	Person *person = [people objectAtIndex:indexPath.row];
	cell.imageView.image = person.image;
    cell.textLabel.text = person.userName;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create and push another view controller.
	// get the correct person out of the people array and initialize the status view controller for that person
	Person *person = [people objectAtIndex:indexPath.row];
	StatusViewController *statusViewController = [[StatusViewController alloc] initWithStyle:UITableViewStyleGrouped person:person];
	
	//push the new view controller onto the navigation stack
	[self.navigationController pushViewController:statusViewController animated:YES];
	[statusViewController release];
}

- (void)dealloc {
	
	//always call the dealloc of the super class
    [super dealloc];
	
	//make sure to deallocate the people array and the operation queue
	[people release];
	[queue release];
}
@end
