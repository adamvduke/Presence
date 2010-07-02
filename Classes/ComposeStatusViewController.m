//
//  ComposeStatusViewController.m
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "CredentialHelper.h"
#import "PresenceContants.h"
#import "TwitterHelper.h"

@interface ComposeStatusViewController ()

- (void)keyboardWillShow:(NSNotification *)note;

@end

@implementation ComposeStatusViewController

@synthesize password;
@synthesize username;
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

-(void)finishedTweet:(BOOL)success
{
	// start the device's network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// start animating the spinner
	[self.spinner stopAnimating];
	
	if (!success) 
	{
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(UpdateFailedTitleKey, @"") 
													   message:NSLocalizedString(UpdateFailedMessageKey, @"") 
													  delegate:nil cancelButtonTitle:NSLocalizedString(DismissKey, @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else 
	{
		// if the update was a success, set the text to nil and dismiss the view
		self.textView.text = nil;
		[self dismiss];
	}
	
}

-(void)beginTweetWithText:(NSString *)text
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	// call the TwitterHelper to update the status
	BOOL success = [TwitterHelper updateStatus:text forUsername:self.username withPassword:self.password];
		
	[self performSelectorOnMainThread:@selector(finishedTweet:) withObject:success ? @"YES" : @"NO" waitUntilDone:NO];

	[pool release];
}

// action to call to post a status update to twitter
- (IBAction)tweetAction
{	
	// disable the text view
	self.isEditable = NO;
	
	// start the device's network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// start animating the spinner
	[self.spinner startAnimating];
	
	NSString *text = textView.text;
	[NSThread detachNewThreadSelector:@selector(beginTweetWithText:) toTarget:self withObject:text];
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.username = [CredentialHelper retrieveUsername];
	self.password = [CredentialHelper retrievePassword];
	
	// if the username and password don't have any values, display an Alert to the user to set them on the setting menu
	if ([self.username length] == 0 || [self.password length] == 0) 
	{
		self.aNavigationItem.rightBarButtonItem.enabled = NO;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(MissingCredentialsTitleKey, @"")
														message:NSLocalizedString(MissingCredentialsMessageKey, @"") 
													   delegate:nil cancelButtonTitle:NSLocalizedString(DismissKey, @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
	}	
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

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

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[aNavigationItem release];
	[charactersLabel release];
	[textView release];
    [super dealloc];
}

@end
