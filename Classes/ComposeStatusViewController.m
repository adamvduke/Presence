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

-(IBAction)cancelAction{
	
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)changeCountLabel{

	charactersLabel.text = [NSString stringWithFormat:@"%d/140",[textView.text length]];
}

-(IBAction)tweetAction{
	
	// MUST ADD USERNAME AND PASSWORD TO POST UPDATES
	BOOL success = [TwitterHelper updateStatus:textView.text forUsername:@"" withPassword:@""];
	[self dismissModalViewControllerAnimated:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        textView.text = @"";
    }
    return self;
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    textView.text = @"";
	charactersLabel.text = @"Characters:";
	countLabel.text = @"000/140";
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
