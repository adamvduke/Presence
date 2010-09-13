//
//  ComposeStatusViewController.h
//  Presence
//
//  Created by Adam Duke on 5/31/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@protocol ComposeStatusViewControllerDelegate;

@interface ComposeStatusViewController : UIViewController <UITextViewDelegate, SA_OAuthTwitterControllerDelegate >
{
	SA_OAuthTwitterEngine				*_engine;
	
	NSString *password;
	NSString *screenName;
	
	// activity indicator for animation during data access
	UIActivityIndicatorView	*spinner;
	
	// IBOutlet for the navigationItem
	IBOutlet UINavigationItem *aNavigationItem;
	
	// IBOutlet for the label that displays the word representing Characters
	IBOutlet UILabel *charactersLabel;
	
	// IBOutlet for the UITextView
	IBOutlet UITextView *textView;
	
	// BOOL to control textView editiability
	BOOL isEditable;
	
	// the delegate
	id<ComposeStatusViewControllerDelegate> delegate;
}

@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UINavigationItem *aNavigationItem;
@property (nonatomic, retain) UILabel *charactersLabel;
@property (nonatomic, retain) UITextView *textView;
@property BOOL isEditable;
@property (nonatomic, retain) id<ComposeStatusViewControllerDelegate> delegate;

// action to call to dismiss this view controller when displayed modally
- (IBAction)dismiss;

// action to call to post a status update to twitter
- (IBAction)tweetAction;

// UITextViewDelegate method to notify the UITextView if it should update the current text with the requested text
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

// called when the UITextView changes
- (void)textViewDidChange:(UITextView *)textView;

@end

@protocol ComposeStatusViewControllerDelegate<NSObject>

- (void)didFinishComposing:(ComposeStatusViewController *)viewController;

@end