//
//  ComposeStatusViewController.h
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface ComposeStatusViewController : UIViewController <UITextViewDelegate>{

	// IBOutlet for the label that displays the word representing Characters
	IBOutlet UILabel *charactersLabel;
	
	// IBOutlet for the label that shows the character count
	IBOutlet UILabel *countLabel;
	
	// IBOutlet for the UITextView
	IBOutlet UITextView *textView;
}

// action to call to dismiss this view controller when displayed modally
-(IBAction)dismiss;

// action to call to post a status update to twitter
-(IBAction)tweetAction;

// UITextViewDelegate method to notify the UITextView if it should update the current text with the requested text
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

// called when the UITextView changes
- (void)textViewDidChange:(UITextView *)textView;

@end
