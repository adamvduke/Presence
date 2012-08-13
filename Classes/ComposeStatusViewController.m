/*  ComposeStatusViewController.m
 *  Presence
 *
 *  Created by Adam Duke on 5/31/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "ADEngineBlock.h"
#import "ComposeStatusViewController.h"
#import "CredentialHelper.h"
#import "PresenceAppDelegate.h"
#import "PresenceConstants.h"

@interface ComposeStatusViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property BOOL isEditable;

- (void)keyboardWillShow:(NSNotification *)note;
- (void)setCharactersEntered:(NSUInteger)characters;
- (void)setTweetButtonStatus;
- (BOOL)textViewHasText;

@end

@implementation ComposeStatusViewController

@synthesize engineBlock, spinner, aNavigationItem, charactersLabel, textView, isEditable, delegate;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    /* return YES for all interface orientations */
    return YES;
}

/* save the current content of the text view to NSUserDefaults */
- (void)saveText
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.textView.text forKey:TweetContentKey];
}

/* action to call to dismiss this view controller when displayed modally, should be called from a
 * successful status update because the value for the TweetContentKey in NSUserDefaults is over
 * written with nil
 */
- (IBAction)dismiss
{
    [self saveText];
    [self.delegate didFinishComposing:self];
}

/* action to call to post a status update to twitter */
- (IBAction)tweetAction
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.isEditable = NO;
    [self.engineBlock sendUpdate:self.textView.text withHandler:^(NSDictionary *result, NSError *error)
     {
         /* stop the device's network activity indicator */
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

         /* if the update was a success, set the text to nil and dismiss the view */
         self.textView.text = nil;
         [self dismiss];
     }];
}

/* UITextViewDelegate method */
- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(!self.isEditable)
    {
        return NO;
    }

    /* if the length of the current text plus the length of the requested text is less than 140
     * characters, return YES else NO
     */
    if([theTextView.text length] + [text length] <= 140)
    {
        return YES;
    }
    return NO;
}

/* Determines if the text view has any text to display */
- (BOOL)textViewHasText
{
    NSString *text = self.textView.text;
    BOOL hasText = [text length] > 0;
    return hasText;
}

/* Sets the text for the label that displays the current character count */
- (void)setCharactersEntered:(NSUInteger)characters
{
    [self setTweetButtonStatus];

    /* update the countLabel's text with the current length of the text */
    NSString *localizedText = NSLocalizedString(CharactersLabelKey, @"");
    NSString *charactersLabelText = [NSString stringWithFormat:@"%@:%u/140", localizedText, characters];
    self.charactersLabel.text = charactersLabelText;
}

/* Sets the "Tweet" button to enabled or disabled depeding
 * on the current state of the engine and text view
 */
- (void)setTweetButtonStatus
{
    BOOL enabled = [self textViewHasText];
    UINavigationItem *navBar = self.aNavigationItem;
    UIBarButtonItem *rightBarButton = navBar.rightBarButtonItem;
    rightBarButton.enabled = enabled;
}

/* executes any logic that should happen when the text
 * in the text view changes
 */
- (void)textViewDidChange:(UITextView *)theTextView
{
    [self setCharactersEntered:[theTextView.text length]];
}

/* override viewWillAppear to do some initialization */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    /* make the view editable if it is appearing */
    self.isEditable = YES;

    /* set the navigation item's title to the localized value */
    self.aNavigationItem.title = NSLocalizedString(ComposeViewTitleKey, @"");

    /* get any previous text out of NSUserDefaults, if the content has length set the
     * UITextView's text to that content */
    NSString *previousText = [[NSUserDefaults standardUserDefaults] objectForKey:TweetContentKey];
    if(previousText != nil)
    {
        self.textView.text = previousText;
    }

    /* set the character count */
    [self setCharactersEntered:[previousText length]];

    /* tell the UITextView to becomeFirstResponder, this brings up the keyboard */
    [self.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTweetButtonStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(self.textView.text != nil)
    {
        [self saveText];
    }
}

/* Implement viewDidLoad to do additional setup after loading the view, typically from a nib. */
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    self.textView.text = @"";

    /* set the cornerRadius property to 8, this creates rounded corners for the UITextView */
    self.textView.layer.cornerRadius = 8;

    /* subscribe to the UIKeyboardWillShowNotification */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

/* When the keyboard becomes visible, do some math to redraw things to the appropriate size */
- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect newTextViewFrame;
    if( UIDeviceOrientationIsPortrait(self.interfaceOrientation) )
    {
        newTextViewFrame = CGRectMake(5.0f, 70.0f, 310.0f, 170.0f);
    }
    else
    {
        newTextViewFrame = CGRectMake(5.0f, 70.0f, 470.0f, 65.0f);
    }
    [self.textView setFrame:newTextViewFrame];

    /* center the spinner in the new text view frame */
    CGRect originalSpinnerFrame = self.spinner.frame;
    CGRect spinnerFrame = CGRectMake(newTextViewFrame.size.width/2 - originalSpinnerFrame.size.width/2,
                                     newTextViewFrame.size.height/2 - originalSpinnerFrame.size.height/2,
                                     originalSpinnerFrame.size.width,
                                     originalSpinnerFrame.size.width);
    [self.spinner setFrame:spinnerFrame];
    [self.textView addSubview:spinner];
}

- (void)viewDidUnload
{
    self.aNavigationItem = nil;
    self.charactersLabel = nil;
    self.textView = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end