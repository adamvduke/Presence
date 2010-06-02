//
//  ComposeStatusViewController.h
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ComposeStatusViewController : UIViewController {

	IBOutlet UILabel *charactersLabel;
	IBOutlet UILabel *countLabel;
	IBOutlet UITextView *textView;
}

-(IBAction)cancelAction;
-(IBAction)changeCountLabel;
-(IBAction)tweetAction;

@end
