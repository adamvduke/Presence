//
//  PersonListViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 Adam Duke. All rights reserved.
//

#import "CredentialHelper.h"
#import "FavoritesHelper.h"
#import "ListViewController.h"
#import "Person.h"
#import "PresenceContants.h"
#import "PresenceAppDelegate.h"
#import "StatusViewController.h"
#import "ValidationHelper.h"

#define kCustomRowCount 7  // enough rows to fill the table if there is no data 
#define kCustomRowHeight 48  // height of each row 
#define kThreadBatchCount 5 // number of rows to create before re-drawing the table view 

@interface ListViewController (Private)

- (void) startIconDownload:(Person *)aPerson forIndexPath:(NSIndexPath *)indexPath;
- (void) beginLoadingTwitterData;
- (void) synchronousLoadTwitterData;
- (void) synchronousLoadPerson:(NSString *)user_id;
- (void) didFinishLoadingPerson;

@end

@implementation ListViewController

@synthesize openRequests;
@synthesize addBarButton;
@synthesize composeBarButton;
@synthesize userIdArray;
@synthesize people;
@synthesize imageDownloadsInProgress;
@synthesize finishedThreads;
@synthesize dataAccessHelper;

- (void)dealloc 
{	
	[addBarButton release];
	[composeBarButton release];
	[userIdArray release];
	[people release];
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
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

// override viewWillAppear to begin the data load
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if(![engine isAuthorized]){
		PresenceAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		engine = [appDelegate getEngineForDelegate:self];
	}
	if ([engine isAuthorized]) {
		[self authSucceededForEngine];
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

// synchronously get the usernames and call beginLoadPerson for each username
- (void)synchronousLoadTwitterData
{
	if (!IsEmpty(self.userIdArray)) {
		
		// start the device's network activity indicator
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	
	// TODO: should this loop be inside the IsEmpty check?
	for (NSString *user_id in userIdArray) 
	{
		[self synchronousLoadPerson:user_id];
	}
}

// synchronously fetch data, initialize a person object, and add it to the list of people
// call the main thread when finished
-(void) synchronousLoadPerson:(NSString *)user_id
{
	Person *person = [dataAccessHelper initPersonByUserId:user_id];
	if (![person isValid]) {
		[person release];
		person = nil;
		
		// get the user's information from Twitter
		[engine getUserInformationFor:user_id];
	}
	else
	{
		[self.people addObject:person];
		[person release];
		[self didFinishLoadingPerson];
	}
}

- (BOOL) dataLoadComplete
{
	return [self.userIdArray count] == [self.people count];
}

// called by synchronousLoadPerson when the load has finished
-(void) didFinishLoadingPerson
{
	// in order to save redrawing the UI after every load, redraw after ever kThreadBatchCount loads
	// or redraw in the case that the queue is on it's last operation
	self.finishedThreads++;
	
	if (self.finishedThreads == kThreadBatchCount || [self dataLoadComplete]) {
		self.finishedThreads = 0;
		
		// reload the table's data
		[self.tableView reloadData];
		
		if ([self dataLoadComplete]) 
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
	ComposeStatusViewController *statusViewController = [[ComposeStatusViewController alloc] 
														 initWithNibName:ComposeStatusViewControllerNibName 
																  bundle:[NSBundle mainBundle]];
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
				[self synchronousLoadPerson:username];
			}
		}
	}
}

#pragma mark -
#pragma mark custom init method
-(id)initAsEditable:(BOOL)isEditable userIdArray:(NSMutableArray *)userIds
{
	
	if (self == [super initWithStyle:UITableViewStylePlain]) {
		
		if (isEditable) {
			self.navigationItem.leftBarButtonItem = self.editButtonItem;
		}
		
		// set the list of users to load
		self.userIdArray = userIds;
		
		//allocate the memory for the NSMutableArray of people on this ViewController
		self.people = [[NSMutableArray alloc]init];
		
		// create a UIBarButtonItem for the right side using the Compose style, this will present the ComposeStatusViewController modally
		UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] 
										   initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
										   target:self action:@selector(presentUpdateStatusController)];
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
			UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
										  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
										  target:self action:@selector(presentAddToFavoritesController)];
			self.addBarButton = addButton;
			[addButton release];
		}
		
		// hold onto the current right bar button (compose) so it can
		// be put back after editing
		self.composeBarButton = self.navigationItem.rightBarButtonItem;
		
		// set the right bar button to the add bar button
		self.navigationItem.rightBarButtonItem = self.addBarButton;
    } 
	else {
		
		// set the right bar button to the compose bar button
		self.navigationItem.rightBarButtonItem = self.composeBarButton;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// if the indexPath.row is the first empty row, the editing style is insert
	// else it's delete
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

- (UITableViewCell *)placeHolderCellForTableView:(UITableView *)tableView
{
	static NSString *PlaceHolderIdentifier = @"PlaceHolder";
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"ListCell";
	
    int peopleCount = [self.people count];
	int idCount = [self.userIdArray count];
	
	// if this is the first row and there are no people to display yet
	// but there should be, display a cell that indicates data is loading
	if (peopleCount == 0 && indexPath.row == 0 && idCount > 0)
	{
		return [self placeHolderCellForTableView:tableView];
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
	
	// Leave cells empty if there's no data yet
	if (peopleCount > 0 && indexPath.row < peopleCount)
	{
		// Set up the cell...
		Person *person = [self.people objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = person.screen_name;
		
		// Only load cached images; defer new downloads until scrolling ends
		if (!person.image)
		{
			// first check the database
			UIImage *anImage = [dataAccessHelper initImageForUserId:person.user_id];
			if (!anImage) 
			{
				if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
				{
					// if there was no image in the database
					// and the tableview is not dragging or decelerating
					// start to download the image
					[self startIconDownload:person forIndexPath:indexPath];
				}
				
				// if a download is deferred or in progress, return a placeholder image
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

// override didSelectRowAtIndexPath to push a StatusViewController onto the navigation stack when a row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	if (!IsEmpty(self.people) > 0) {
		
		// get the correct person out of the people array and initialize the status view controller for that person
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
	// check for a download in progress for the indexPath
	// if there isn't one, create one and start the download
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
    if (!IsEmpty(self.userIdArray) > 0)
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
		[dataAccessHelper saveOrUpdatePerson:person];
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

#pragma mark -
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username
{
	[CredentialHelper saveAuthData:data];
	[CredentialHelper saveUsername:username];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
	return [CredentialHelper retrieveAuthData];
}

- (void)authSucceededForEngine
{
	NSString *screenName = [CredentialHelper retrieveUsername];
	
	// check the userIdArray, because it may have been set already
	if( !IsEmpty(screenName) && IsEmpty(userIdArray) )
	{
		[engine getFollowedIdsForUsername:screenName];
	}
	else if(IsEmpty(people)){
		[self synchronousLoadTwitterData];
	}	
}

//- (void) twitterOAuthConnectionFailedWithData: (NSData *) data; 
#pragma mark -
#pragma mark EngineDelegate

// These delegate methods are called after a connection has been established
- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Request succeeded %@, response pending.", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Request failed %@, with error %@.", connectionIdentifier, [error localizedDescription]);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
	Person *person = [[Person alloc]initPersonWithInfo:[userInfo objectAtIndex:0]];
	
	// this person is not yet in the database
	if ([person isValid]) {
		[dataAccessHelper saveOrUpdatePerson:person];
		[self.people addObject:person];
	}
	[person release];
	[self didFinishLoadingPerson];
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{	
	NSMutableArray *idsArray = [NSMutableArray array];
	for(NSDictionary *dictionary in miscInfo)
	{
		for (NSString *key in [dictionary allKeys]) {
			[idsArray addObject:[dictionary objectForKey:key]];
		}
	}
	self.userIdArray = idsArray;
	[self beginLoadingTwitterData];
}

@end
