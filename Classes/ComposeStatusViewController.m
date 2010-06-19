//
//  ComposeStatusViewController.m
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "PresenceContants.h"
#import "TwitterHelper.h"

@implementation ComposeStatusViewController

@synthesize password;
@synthesize username;
@synthesize aNavigationItem;
@synthesize charactersLabel;
@synthesize textView;
@synthesize delegate;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// return YES for all interface orientations
	return YES;
}

// save the current content of the text view to NSUserDefaults
-(void)saveText
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.textView.text forKey:TweetContentKey];
}

// action to call to dismiss this view controller when displayed modally, should be called from a successful status update because
// the value for the TweetContentKey in NSUserDefaults is over written with nil
-(IBAction)dismiss
{
	[self saveText];
	[self.delegate didFinishComposing:self];
}

// action to call to post a status update to twitter
-(IBAction)tweetAction
{	
	// call the TwitterHelper to update the status
	BOOL success = [TwitterHelper updateStatus:textView.text forUsername:self.username withPassword:self.password];
	
	// if the update was not a sucess, display an error message and save the text
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

// UITextViewDelegate method
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
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
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.username = [[NSUserDefaults standardUserDefaults]objectForKey:UsernameKey];
	self.password = [[NSUserDefaults standardUserDefaults] objectForKey:PasswordKey];
	
	// if the username and password don't have any values, display an Alert to the user to set them on the setting menu
	if ([self.username length] == 0 || [self.password length] == 0) 
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(MissingCredentialsTitleKey, @"")
														message:NSLocalizedString(MissingCredentialsMessageKey, @"") 
													   delegate:nil cancelButtonTitle:NSLocalizedString(DismissKey, @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
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

-(void)viewWillDisappear:(BOOL)animated
{
	if (self.textView.text != nil) 
	{
		[self saveText];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.textView.text = @"";
	
	// set the cornerRadius property to 8, this creates rounded corners for the UITextView
	self.textView.layer.cornerRadius = 8;
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
	[aNavigationItem release];
	[charactersLabel release];
	[textView release];
    [super dealloc];
}

@end
