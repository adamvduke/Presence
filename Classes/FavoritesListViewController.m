/*  ListViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 11/11/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import "ADEngineBlock.h"
#import "ADSharedMacros.h"
#import "CredentialHelper.h"
#import "DataAccessHelper.h"
#import "FavoritesHelper.h"
#import "FavoritesListViewController.h"
#import "NINetworkActivity.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"
#import "StatusViewController.h"
#import "User.h"

#define kCustomRowHeight 48  /* height of each row */
#define kThreadBatchCount 5 /* number of rows to create before re-drawing the table view */

@interface FavoritesListViewController ()

@property (nonatomic, strong) UIBarButtonItem *addBarButton;
@property (nonatomic, strong) NSMutableArray *pendingFavorites;
@property (nonatomic, strong) UIBarButtonItem *composeBarButton;
@property (nonatomic, strong) NSMutableArray *userIdArray;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property int finishedThreads;

- (void)startIconDownload:(User *)aUser forIndexPath:(NSIndexPath *)indexPath;
- (void)startDataLoad;
- (void)startUserLoad:(NSString *)user_id;
- (void)infoRecievedForUser:(User *)user;
- (void)didFinishLoadingUser;

/* IconDownloader delegate protocol */
- (void)imageDidLoad:(NSIndexPath *)indexPath;
@end

@implementation FavoritesListViewController

@synthesize composeBarButton;
@synthesize userIdArray;
@synthesize users;
@synthesize imageDownloadsInProgress;
@synthesize finishedThreads;
@synthesize dataAccessHelper;
@synthesize addBarButton;
@synthesize pendingFavorites;

#pragma mark -
#pragma mark custom init method

- (id)initWithUserIdArray:(NSMutableArray *)userIds
{
    if(self = [super initWithStyle:UITableViewStylePlain])
    {
        /* set the list of users to load */
        self.userIdArray = userIds;
    }
    return self;
}

#pragma mark -
#pragma mark dealloc

- (void)presentAddToFavoritesAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(AddToFavoritesKey, @"")
                                                    message:NSLocalizedString(EnterTwitterIDKey, @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(CancelKey, @"")
                                          otherButtonTitles:NSLocalizedString(OKKey, @""), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setPlaceholder:NSLocalizedString(TwitterIDKey, @"")];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString *upperCaseUsername = [textField.text uppercaseString];
    if(upperCaseUsername)
    {
        if(!pendingFavorites)
        {
            self.pendingFavorites = [[NSMutableArray alloc] init];
        }
        [pendingFavorites addObject:upperCaseUsername];
        [self startUserLoad:upperCaseUsername];
    }
}

- (void)updateFavoritesWithUser:(User *)user
{
    NSString *upperCaseUsername = [user.screen_name uppercaseString];
    if([pendingFavorites containsObject:upperCaseUsername])
    {
        [userIdArray addObject:user.user_id];
        [FavoritesHelper saveFavorites:userIdArray];
        [pendingFavorites removeObject:upperCaseUsername];
    }
}

#pragma mark -
#pragma mark UIViewController methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    /* return YES for all interface orientations */
    return YES;
}

- (void)viewDidLoad
{
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];

    /* allocate the memory for the NSMutableArray of people on this ViewController */
    self.users = [[NSMutableArray alloc] init];

    /* create a UIBarButtonItem for the right side using the Compose style, this will
     * present the ComposeStatusViewController modally */
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                    target:self
                                                                                    action:@selector(presentUpdateStatusController)];
    [self.navigationItem setRightBarButtonItem:rightBarButton animated:NO];
    self.navigationItem.rightBarButtonItem.enabled = YES;

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDataLoad];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    /* Releases the view if it doesn't have a superview. */
    [super didReceiveMemoryWarning];

    /* terminate all pending download connections */
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];

    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];

    /* for each user, determine if the user is visible
     * if not, set the user's statusUpdate and image properties to nil
     */
    for(int i = 0; i < [self.users count]; i++)
    {
        BOOL visible = NO;
        for(NSIndexPath *path in visiblePaths)
        {
            if(path.row == i)
            {
                visible = YES;
                break;
            }
        }
        if(!visible)
        {
            User *user = [users objectAtIndex:i];
            if(user)
            {
                user.statusUpdates = nil;
                user.image = nil;
            }
        }
    }
}

#pragma mark -
#pragma mark Data loading

- (void)startDataLoad
{
    if ([self.users count] > 0)
    {
        return;
    }
    [self.users removeAllObjects];
    if( !IsEmpty(self.userIdArray) )
    {
        for(NSString *user_id in self.userIdArray)
        {
            [self startUserLoad:user_id];
        }
    }
}

- (void)infoRecievedForUser:(User *)user
{
    [dataAccessHelper saveOrUpdateUser:user];
    [self.users addObject:user];
}

- (void)startUserLoad:(NSString *)user_id
{
    User *user = [dataAccessHelper userByUserId:user_id];
    if(![user isValid])
    {
        user = nil;

        /* TODO: the user_id might actually be a string... */
        NSInteger integer = [user_id integerValue];
        NSNumber *number = [NSNumber numberWithInteger:integer];
        NINetworkActivityTaskDidStart();
        [self.engineBlock showUser:[number unsignedLongLongValue] withHandler:^(NSDictionary *result, NSError *error)
         {
             NINetworkActivityTaskDidFinish();
             User *user = [[User alloc] initWithInfo:result];

             /* this user is not yet in the database */
             if([user isValid])
             {
                 [self infoRecievedForUser:user];
                 [self updateFavoritesWithUser:user];
             }
             [self didFinishLoadingUser];
         }];
    }
    else
    {
        [self.users addObject:user];
        [self didFinishLoadingUser];
    }
}

- (BOOL)dataLoadComplete
{
    return [self.userIdArray count] == [self.users count];
}

/* called by synchronousLoadUser when the load has finished */
- (void)didFinishLoadingUser
{
    /* in order to save redrawing the UI after every load, redraw after ever kThreadBatchCount
     * loads or redraw in the case that the queue is on it's last operation
     */
    self.finishedThreads++;
    if(self.finishedThreads == kThreadBatchCount || [self dataLoadComplete])
    {
        self.finishedThreads = 0;

        /* reload the table's data */
        [self.tableView reloadData];
        if([self dataLoadComplete])
        {
            /* flash the scroll indicators to show give the user an idea of how long the
             * list is */
            [self.tableView flashScrollIndicators];
        }
    }
}

#pragma mark -
#pragma mark Modal ComposeStatusViewController

/* show a modal view controller that will allow a user to compose a twitter status */
- (void)presentUpdateStatusController
{
    ComposeStatusViewController *statusViewController = [[ComposeStatusViewController alloc] initWithNibName:ComposeStatusViewControllerNibName
                                                                                                      bundle:[NSBundle mainBundle]];
    statusViewController.delegate = self;
    statusViewController.engineBlock = self.engineBlock;
    [self.navigationController presentModalViewController:statusViewController animated:YES];
}

/* ComposeStatusViewControllerDelegate protocol */
- (void)didFinishComposing:(ComposeStatusViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view methods
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if(editing)
    {
        if(!self.addBarButton)
        {
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                       target:self
                                                                                       action:@selector(presentAddToFavoritesAlert)];
            self.addBarButton = addButton;
        }

        /* hold onto the current right bar button (compose) so it can
         * be put back after editing
         */
        self.composeBarButton = self.navigationItem.rightBarButtonItem;

        /* set the right bar button to the add bar button */
        self.navigationItem.rightBarButtonItem = self.addBarButton;
    }
    else
    {
        /* set the right bar button to the compose bar button */
        self.navigationItem.rightBarButtonItem = self.composeBarButton;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableview:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger sourceRow = sourceIndexPath.row;
    NSUInteger destinationRow = destinationIndexPath.row;
    User *user = [self.users objectAtIndex:sourceRow];
    NSString *userId = [self.userIdArray objectAtIndex:sourceRow];
    [self.users removeObjectAtIndex:sourceRow];
    [self.userIdArray removeObjectAtIndex:sourceRow];
    [self.users insertObject:user atIndex:destinationRow];
    [self.userIdArray insertObject:userId atIndex:destinationRow];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* If row is deleted, remove it from the list. */
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.users removeObjectAtIndex:indexPath.row];
        [self.userIdArray removeObjectAtIndex:indexPath.row];
        [FavoritesHelper saveFavorites:self.userIdArray];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/* Customize the number of rows per section */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.users count];
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
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PlaceHolderIdentifier];
        cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.detailTextLabel.text = NSLocalizedString(LoadingKey, @"");
    return cell;
}

/* Customize the appearance of table view cells. */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";

    int peopleCount = [self.users count];
    int idCount = [self.userIdArray count];

    /* if this is the first row and there are no people to display yet
     * but there should be, display a cell that indicates data is loading
     */
    if(peopleCount == 0 && indexPath.row == 0 && idCount > 0)
    {
        return [self placeHolderCellForTableView:tableView];
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    /* Leave cells empty if there's no data yet */
    if(peopleCount > 0 && indexPath.row < peopleCount)
    {
        /* Set up the cell... */
        User *user = [self.users objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = user.screen_name;

        /* Only load cached images; defer new downloads until scrolling ends */
        if(!user.image)
        {
            /* first check the database */
            UIImage *anImage = [dataAccessHelper imageForUserId:user.user_id];
            if(!anImage)
            {
                if(self.tableView.dragging == NO && self.tableView.decelerating == NO)
                {
                    /* if there was no image in the database
                     * and the tableview is not dragging or decelerating
                     * start to download the image
                     */
                    [self startIconDownload:user forIndexPath:indexPath];
                }

                /* if a download is deferred or in progress, return a placeholder
                 * image */
                cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            }
            else
            {
                user.image = anImage;
                cell.imageView.image = user.image;
            }
        }
        else
        {
            cell.imageView.image = user.image;
        }
    }
    return cell;
}

/* override didSelectRowAtIndexPath to push a StatusViewController onto the navigation stack when a
 * row is selected */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!IsEmpty(self.users) > 0)
    {
        /* get the correct user out of the people array and initialize the status view
         * controller for that user */
        User *user = [users objectAtIndex:indexPath.row];
        StatusViewController *statusViewController = [[StatusViewController alloc] initWithUser:user dataAccessHelper:dataAccessHelper engine:self.engineBlock];

        /* push the new view controller onto the navigation stack */
        [self.navigationController pushViewController:statusViewController animated:YES];
    }
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(User *)aUser forIndexPath:(NSIndexPath *)indexPath
{
    /* check for a download in progress for the indexPath
     * if there isn't one, create one and start the download
     */
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if(iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.user = aUser;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

/* this method is used in case the user scrolled into a set of cells that don't have their app icons
 * yet */
- (void)loadImagesForOnscreenRows
{
    if(!IsEmpty(self.userIdArray) > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for(NSIndexPath *indexPath in visiblePaths)
        {
            User *user = [self.users objectAtIndex:indexPath.row];
            if(!user.image)
            {
                /* avoid the app icon download if the app already has an icon */
                [self startIconDownload:user forIndexPath:indexPath];
            }
        }
    }
}

/* called by our ImageDownloader when an icon is ready to be displayed */
- (void)imageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if(iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];

        /* Display the newly loaded image */
        User *user = iconDownloader.user;
        [dataAccessHelper saveOrUpdateUser:user];
        cell.imageView.image = user.image;
    }
    [imageDownloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

/* Load images for all onscreen rows when scrolling is finished */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end