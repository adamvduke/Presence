//
//  PersonListViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CredentialHelper.h"
#import "FavoritesHelper.h"
#import "ListViewController.h"
#import "Person.h"
#import "PresenceContants.h"
#import "StatusViewController.h"
#import "TwitterHelper.h"
#import "ValidationHelper.h"

#define kCustomRowCount 7
#define kCustomRowHeight 48
#define kThreadBatchCount 15

@interface ListViewController ()

- (void) startIconDownload:(Person *)aPerson forIndexPath:(NSIndexPath *)indexPath;
- (void) beginLoadingTwitterData;
- (void) synchronousLoadTwitterData;
- (void) beginLoadPerson:(NSString *)userId;
- (void) synchronousLoadPerson:(NSString *)userId;
- (void) didFinishLoadingPerson;

@end

@implementation ListViewController

@synthesize addBarButton;
@synthesize composeBarButton;
@synthesize userIdArray;
@synthesize people;
@synthesize imageDownloadsInProgress;
@synthesize queue;
@synthesize finishedThreads;
@synthesize dataAccessHelper;

- (void)dealloc 
{	
	// make sure to deallocate the people array and the operation queue
	[addBarButton release];
	[composeBarButton release];
	[userIdArray release];
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
	
	NSString *screenName = [CredentialHelper retrieveScreenName];
	
	// if the username and password don't have any values, display an Alert to the user to set them on the setting menu
	if ( [screenName length] == 0 ) 
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(MissingCredentialsTitleKey, @"")
														message:NSLocalizedString(MissingCredentialsMessageKey, @"") 
													   delegate:nil cancelButtonTitle:NSLocalizedString(DismissKey, @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}

// override viewWillAppear to begin the data load
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSString *screenName = [CredentialHelper retrieveScreenName];
	
	// if the username and password don't have any values, display an Alert to the user to set them on the setting menu
	if ( [screenName length] == 0 ) 
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}

	if([screenName length] > 0 && [self.userIdArray count] == 0)
	{
		self.userIdArray = [TwitterHelper fetchFollowingIdsForScreenName:screenName];
	}
	
	// if the array of Person objects is empty, start loading data
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
	[allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	// for each person, determine if the person is visible
	// if not, set the person's statusUpdate and image properties to nil
	for (int i = 0; i < [people count]; i++) {
		
		BOOL visible = NO;
		for (NSIndexPath *path in visiblePaths)
		{
			if (path.row == i ) {
				visible = YES;
				break;
			}
		}
		
		if (!visible) {			
			Person *person = [people objectAtIndex:i];
			if (person) {
				person.statusUpdates = nil;
				person.image = nil;
			}
		}
	}
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
	if (self.userIdArray != nil && [self.userIdArray count] > 0 ) {
		
		// start the device's network activity indicator
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	
	for (NSString *userId in userIdArray) 
	{
		[self beginLoadPerson:userId];
	}
}

// start to load a person object asynchronously
- (void) beginLoadPerson:(NSString *)userId
{
	//create an NSInvocationOperation and add it to the queue
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadPerson:) object:userId];
	[self.queue addOperation:operation];
	[operation release];
}

// synchronously fetch data, initialize a person object, and add it to the list of people
// call the main thread when finished
-(void) synchronousLoadPerson:(NSString *)userId
{
	Person *person = [dataAccessHelper initPersonByUserId:userId];
	if (![Person isValid:person]) {
		
		// TODO: what happens with the initially allocated Person object
		// when it's reallocated below?
		// get the user's information from Twitter
		NSDictionary *userInfo = [TwitterHelper fetchInfoForUsername:userId];
		if (!IsEmpty(userInfo) && !IsEmpty(userId)) 
		{
			person = [[Person alloc]initPersonWithInfo:userInfo];
		}
	}
	if ([Person isValid:person]) 
	{
		[self.people addObject:person];
		[dataAccessHelper savePerson:person];
	}

	[person release];
	
	// call the main thread to notify that the person has finished loading
	[self performSelectorOnMainThread:@selector(didFinishLoadingPerson) withObject:nil waitUntilDone:NO];
}

// called by synchronousLoadPerson when the load has finished
-(void) didFinishLoadingPerson
{
	self.finishedThreads++;
	
	if (self.finishedThreads == kThreadBatchCount || [[queue operations] count] <= 1) {
		self.finishedThreads = 0;
		
		// reload the table's data
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

-(void)presentAddToFavoritesController
{
	// TODO: localize the alert message labels
	// TODO: Decide if the alertview with a text field is appropriate
	// or if a modal view should be used, or if the favorites should be 
	// added to from the status views with a "Favorite" button
	// open a alert with text field,  OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add to Favorites" message:@"Enter a username."
												   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
	UITextView *alertTextField = nil;
	CGRect frame = CGRectMake(14, 45, 255, 23);
	if(!alertTextField) {
		alertTextField = [[UITextField alloc] initWithFrame:frame];
		alertTextField.layer.cornerRadius = 8;
		alertTextField.textColor = [UIColor blackColor];
		alertTextField.textAlignment = UITextAlignmentCenter;
		alertTextField.font = [UIFont systemFontOfSize:14.0];		
		alertTextField.backgroundColor = [UIColor whiteColor];
		alertTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		alertTextField.delegate = self;
	}
	
	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 45.0);
	[alert setTransform:myTransform];
	[alert addSubview:alertTextField];
	[alert show];
	[alertTextField becomeFirstResponder];
	[alertTextField release];
	
	[alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		for(UIView *subview in alertView.subviews)
		{
			if ([subview isKindOfClass:[UITextField class]]) {
				UITextField *textField = (UITextField *)subview;
				NSString *username = textField.text;
				[self.userIdArray addObject:username];
				[FavoritesHelper saveFavorites:userIdArray];
				[self beginLoadPerson:username];
			}
		}
	}
}

#pragma mark -
#pragma mark custom init method
-(id)initAsEditable:(BOOL)isEditable userIdArray:(NSMutableArray *)userIds dataAccessHelper:(DataAccessHelper *)accessHelper
{
	
	if (self == [super initWithStyle:UITableViewStylePlain]) {
		
		if (isEditable) {
			self.navigationItem.leftBarButtonItem = self.editButtonItem;
		}
		
		// set the DataAccessHelper
		self.dataAccessHelper = accessHelper;
		
		// set the list of users to load
		self.userIdArray = userIds;
		
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if (editing) {
		if (!self.addBarButton) {
			UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentAddToFavoritesController)];
			self.addBarButton = addButton;
			[addButton release];
		}
		self.composeBarButton = self.navigationItem.rightBarButtonItem;
		self.navigationItem.rightBarButtonItem = self.addBarButton;
    } else {
		self.navigationItem.rightBarButtonItem = self.composeBarButton;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.row == [self.people count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

-(BOOL)tableview:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
	NSUInteger sourceRow = sourceIndexPath.row;
	NSUInteger destinationRow = destinationIndexPath.row;
	Person *person = [[self.people objectAtIndex:sourceRow] retain];
	NSString *userId = [[self.userIdArray objectAtIndex:sourceRow]retain];
    [self.people removeObjectAtIndex:sourceRow];
	[self.userIdArray removeObjectAtIndex:sourceRow];
    [self.people insertObject:person atIndex:destinationRow];
	[self.userIdArray insertObject:userId atIndex:destinationRow];
    [person release];
	[userId release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.people removeObjectAtIndex:indexPath.row];
		[self.userIdArray removeObjectAtIndex:indexPath.row];
		[FavoritesHelper saveFavorites:self.userIdArray];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCustomRowHeight;
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
	int idCount = [self.userIdArray count];
	
	if (nodeCount == 0 && indexPath.row == 0 && idCount > 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceHolderIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PlaceHolderIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
		cell.detailTextLabel.text = NSLocalizedString(LoadingKey, @"");
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
		cell.textLabel.text = person.screenName;
		
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
	
	if ([self.people count] > 0) {
		
		Person *person = [people objectAtIndex:indexPath.row];
		StatusViewController *statusViewController = [[StatusViewController alloc] initWithPerson:person dataAccessHelper:dataAccessHelper];
		
		// push the new view controller onto the navigation stack
		[self.navigationController pushViewController:statusViewController animated:YES];
		[statusViewController release];
	}
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
    if ([self.userIdArray count] > 0)
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
- (void)imageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
		Person *person = iconDownloader.person;
		[dataAccessHelper savePerson:person];
        cell.imageView.image = person.image;
    }
	[imageDownloadsInProgress removeObjectForKey:indexPath];
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
