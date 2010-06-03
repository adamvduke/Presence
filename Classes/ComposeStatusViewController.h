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

	IBOutlet UILabel *charactersLabel;
	IBOutlet UILabel *countLabel;
	IBOutlet UITextView *textView;
}

-(IBAction)dismiss;
-(IBAction)tweetAction;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)textViewDidChange:(UITextView *)textView;

@end
