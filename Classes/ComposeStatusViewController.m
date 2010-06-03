//
//  ComposeStatusViewController.m
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeStatusViewController.h"
#import "TwitterHelper.h"


@implementation ComposeStatusViewController

-(IBAction)dismiss{
	
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)tweetAction{
	
	// MUST ADD USERNAME AND PASSWORD TO POST UPDATES
	BOOL success = [TwitterHelper updateStatus:textView.text forUsername:@"" withPassword:@""];
	if (!success) {
		
		//Display an error message
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update failed!" message:@"Your update failed. Check your network settings and try again." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
	    [alert release];
		
		//TODO: Save the contents of the update somewhere so that it can be re populated
	}
	else {
		
		[self dismiss];
	}
}

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	
	if ([theTextView.text length] + [text length] <= 140) {
		return YES;
	}
	return NO;
}

- (void)textViewDidChange:(UITextView *)theTextView{

	countLabel.text = [NSString stringWithFormat:@"%d/140",[theTextView.text length]];

}

-(void)viewWillAppear:(BOOL)animated{

	[super viewWillAppear:animated];
	[textView becomeFirstResponder];
	textView.layer.cornerRadius = 8;

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    textView.text = @"";
	charactersLabel.text = @"Characters:";
	countLabel.text = @"0/140";
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}*/


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
