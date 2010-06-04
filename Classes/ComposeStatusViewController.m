//
//  ComposeStatusViewController.m
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "ErrorHelper.h"
#import "PresenceContants.h"
#import "TwitterHelper.h"

@implementation ComposeStatusViewController

// save the current content of the text view to NSUserDefaults
-(void)saveText{
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:textView.text forKey:TweetContentKey];
}

// action to call to dismiss this view controller when displayed modally, should be called from a successful status update because
// the value for the TweetContentKey in NSUserDefaults is over written with nil
-(IBAction)dismiss{

	[self saveText];
	[self dismissModalViewControllerAnimated:YES];
}

// action to call to post a status update to twitter
-(IBAction)tweetAction{
	
	// get the username and password out of NSUserDefaults
	NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:UsernameKey];
	NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:PasswordKey];
	
	// if the username and password don't have any values, display an Alert to the user to set them on the setting menu
	if (![username length] > 0 && ![password length] > 0) {
		
		//TODO: localize these strings
		[ErrorHelper displayErrorWithTitle:@"Invalid Credentials" Message:@"Please set your credentials in the Settings Menu" CloseButtonTitle:@"OK"];
		return;
	}
	
	// call the TwitterHelper to update the status
	BOOL success = [TwitterHelper updateStatus:textView.text forUsername:username withPassword:password];
	
	// if the update was not a sucess, display an error message and save the text
	if (!success) {
		
		//TODO: Localize these strings
		[ErrorHelper displayErrorWithTitle:@"Update Failed" Message:@"Your update failed. Check your network settings and try again." CloseButtonTitle:@"Close"];	
		return;
	}
	else {
		
		// if the update was a success, set the text to nil and dismiss the view
		textView.text = nil;
		[self dismiss];
	}
}

// UITextViewDelegate method
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	
	// if the length of the current text plus the length of the requested text is less than 140 characters, return YES
	// else NO
	if ([theTextView.text length] + [text length] <= 140) {
		return YES;
	}
	return NO;
}

// UITextViewDelegate method
- (void)textViewDidChange:(UITextView *)theTextView{

	// update the countLabel's text with the current length of the text
	countLabel.text = [NSString stringWithFormat:@"%d/140",[theTextView.text length]];

}

// override viewWillAppear to do some initialization
-(void)viewWillAppear:(BOOL)animated{

	[super viewWillAppear:animated];
	
	// get any previous text out of NSUserDefaults, if the content has length set the UITextView's text to that content
	NSString *previousText = [[NSUserDefaults standardUserDefaults] objectForKey:TweetContentKey];
	if ([previousText length] > 0 ) {
		textView.text = previousText;
	}
	
	// tell the UITextView to becomeFirstResponder, this brings up the keyboard
	[textView becomeFirstResponder];
	
	// set the cornerRadius property to 8, this creates rounded corners for the UITextView
	textView.layer.cornerRadius = 8;
}

-(void)viewWillDisappear:(BOOL)animated{

	if (textView.text != nil) {
		[self saveText];
	}
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	//TODO: localize these strings
	textView.text = @"";
	charactersLabel.text = @"Characters:";
	countLabel.text = @"0/140";
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

- (void)dealloc {
    [super dealloc];
}

@end
