/*  ComposeStatusViewController.h
 *  Presence
 *
 *  Created by Adam Duke on 5/31/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class ADEngineBlock;

@protocol ComposeStatusViewControllerDelegate;

@interface ComposeStatusViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) ADEngineBlock *engineBlock;
@property (nonatomic, strong) IBOutlet UINavigationItem *aNavigationItem;
@property (nonatomic, strong) IBOutlet UILabel *charactersLabel;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, unsafe_unretained) id<ComposeStatusViewControllerDelegate> delegate;

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