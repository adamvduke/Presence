/*  ComposeStatusViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 5/31/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol ComposeStatusViewControllerDelegate;

@interface ComposeStatusViewController : UIViewController <UITextViewDelegate, SA_OAuthTwitterControllerDelegate, SA_OAuthTwitterEngineDelegate>
{
	/* IBOutlet for the navigationItem */
	IBOutlet UINavigationItem *aNavigationItem;

	/* IBOutlet for the label that displays the word representing Characters */
	IBOutlet UILabel *charactersLabel;

	/* IBOutlet for the UITextView */
	IBOutlet UITextView *textView;

	/* the delegate */
	id<ComposeStatusViewControllerDelegate> delegate;

	@private
	SA_OAuthTwitterEngine *engine;
	UIActivityIndicatorView *spinner;
	BOOL isEditable;
}

@property (nonatomic, retain) UINavigationItem *aNavigationItem;
@property (nonatomic, retain) UILabel *charactersLabel;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) id<ComposeStatusViewControllerDelegate> delegate;

/* action to call to dismiss this view controller when displayed modally */
- (IBAction)dismiss;

/* action to call to post a status update to twitter */
- (IBAction)tweetAction;

/* UITextViewDelegate method to notify the UITextView if it should update the current text with the
 * requested text */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

/* called when the UITextView changes */
- (void)textViewDidChange:(UITextView *)textView;

@end

@protocol ComposeStatusViewControllerDelegate<NSObject>

- (void)didFinishComposing:(ComposeStatusViewController *)viewController;

@end