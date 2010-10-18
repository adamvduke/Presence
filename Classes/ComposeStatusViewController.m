//
//  ComposeStatusViewController.m
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "CredentialHelper.h"
#import "PresenceContants.h"

@interface ComposeStatusViewController (Private)

- (void)keyboardWillShow:(NSNotification *)note;

@end

@implementation ComposeStatusViewController

@synthesize spinner;
@synthesize aNavigationItem;
@synthesize charactersLabel;
@synthesize textView;
@synthesize isEditable;
@synthesize delegate;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// return YES for all interface orientations
	return YES;
}

// save the current content of the text view to NSUserDefaults
- (void)saveText
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.textView.text forKey:TweetContentKey];
}

// action to call to dismiss this view controller when displayed modally, should be called from a successful status update because
// the value for the TweetContentKey in NSUserDefaults is over written with nil
- (IBAction)dismiss
{
	[self saveText];
	[self.delegate didFinishComposing:self];
}

// action to call to post a status update to twitter
- (IBAction)tweetAction
{	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.isEditable = NO;
	[engine sendUpdate:textView.text];
}

// UITextViewDelegate method
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if(!self.isEditable)
	{
		return NO;
	}
	
	// if the length of the current text plus the length of the requested text is less than 140 characters, return YES
	// else NO
	if ([theTextView.text length] + [text length] <= 140) 
	{
		return YES;
	}
	return NO;
}

// UITextViewDelegate method
- (void)textViewDidChange:(UITextView *)theTextView
{
	// update the countLabel's text with the current length of the text
	NSString *localizedText = NSLocalizedString(CharactersLabelKey, @"");
	NSString *charactersLabelText = [NSString stringWithFormat:@"%@:%d/140",localizedText, [theTextView.text length]];
	self.charactersLabel.text = charactersLabelText;
}

// override viewWillAppear to do some initialization
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// make the view editable if it is appearing
	self.isEditable = YES;
	
	// set the navigation item's title to the localized value
	self.aNavigationItem.title = NSLocalizedString(ComposeViewTitleKey, @"");
	
	// get any previous text out of NSUserDefaults, if the content has length set the UITextView's text to that content
	NSString *previousText = [[NSUserDefaults standardUserDefaults] objectForKey:TweetContentKey];
	if (previousText != nil ) 
	{
		self.textView.text = previousText;
	}
	
	// tell the UITextView to becomeFirstResponder, this brings up the keyboard
	[self.textView becomeFirstResponder];
}

- (void) viewDidAppear: (BOOL)animated {
	if (engine) return;
	engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	engine.consumerKey = kOAuthConsumerKey;
	engine.consumerSecret = kOAuthConsumerSecret;
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: engine delegate: self];
	
	if (controller)
	{
		[self presentModalViewController: controller animated: YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (self.textView.text != nil) 
	{
		[self saveText];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	self.textView.text = @"";
	
	// set the cornerRadius property to 8, this creates rounded corners for the UITextView
	self.textView.layer.cornerRadius = 8;
	
	// subscribe to the UIKeyboardWillShowNotification
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification 
											   object:nil];
}

// When the keyboard becomes visible, do some math to redraw things to the appropriate size
- (void)keyboardWillShow:(NSNotification *)note
{
	CGRect keyboardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGRect windowFrame = self.view.frame;
	CGRect textViewFrame = self.textView.frame;
	CGPoint textViewOrigin = textViewFrame.origin;
	CGFloat textViewHeight;
	if(UIDeviceOrientationIsLandscape(self.interfaceOrientation))
	{
		// the concept of width and height don't change with respect to portrait orientation
		// when the phone is rotated, in order to calculate what a user views as height in 
		// landscape the calculations should be done on the widths
		textViewHeight = windowFrame.size.width - keyboardFrame.size.width - textViewOrigin.y;
	}
	else 
	{
		textViewHeight = windowFrame.size.height - keyboardFrame.size.height - textViewOrigin.y;
	}
	CGRect newTextViewFrame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textViewHeight);
	[self.textView setFrame:newTextViewFrame];
	
	// re-center the spinner in the new text view frame
	CGRect originalSpinnerFrame = self.spinner.frame;
	CGRect spinnerFrame = CGRectMake(newTextViewFrame.size.width/2 - originalSpinnerFrame.size.width/2, 
									 newTextViewFrame.size.height/2 - originalSpinnerFrame.size.height/2, 
									 originalSpinnerFrame.size.width, 
									 originalSpinnerFrame.size.width);
	[self.spinner setFrame:spinnerFrame];
	[self.textView addSubview:spinner];
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
#pragma mark -
#pragma mark SA_OAuthTwitterControllerDelegate

- (void)OAuthTwitterController:(SA_OAuthTwitterController *)controller authenticatedWithUsername:(NSString *)username 
{
	// save the username
	[CredentialHelper saveUsername:username];
	
	// log the username for debug purposes
	NSLog(@"Authenicated for %@", username);
}

- (void)OAuthTwitterControllerFailed:(SA_OAuthTwitterController *)controller
{
	//TODO: Handle failed authentication
	NSLog(@"Authentication Failed!");
}

- (void)OAuthTwitterControllerCanceled:(SA_OAuthTwitterController *)controller
{
	//TODO: Handle canceled authentication
	NSLog(@"Authentication Canceled.");
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
	// stop the device's network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(UpdateFailedTitleKey, @"") 
												   message:NSLocalizedString(UpdateFailedMessageKey, @"") 
												  delegate:nil cancelButtonTitle:NSLocalizedString(DismissKey, @"") 
										 otherButtonTitles:nil];
	[alert show];
	[alert release];
	return;
	NSLog(@"Request failed %@, with error %@.", connectionIdentifier, [error localizedDescription]);
}

// These delegate methods are called after all results are parsed from the connection. If 
// the deliveryOption is configured for MGTwitterEngineDeliveryAllResults (the default), a
// collection of all results is also returned.
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
	// stop the device's network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// if the update was a success, set the text to nil and dismiss the view
	self.textView.text = nil;
	[self dismiss];
}
- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"Calling directMessagesReceived for request %@", connectionIdentifier);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"Calling userInfoReceived for request %@", connectionIdentifier);
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"Calling miscInfoReceived for request %@", connectionIdentifier);
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[aNavigationItem release];
	[charactersLabel release];
	[textView release];
	[super dealloc];
}
@end
