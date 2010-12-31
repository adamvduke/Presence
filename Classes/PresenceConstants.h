/*  PresenceConstants.h
 *  Presence
 *
 *  Created by Adam Duke on 6/3/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

/*
 * Keys for finding localizable strings
 */

/* key for finding the localized title of the "Following" view */
extern NSString *const ListViewControllerTitleKey;

/* key for finding the localized title of the "Favorites" view */
extern NSString *const FavoritesViewControllerTitleKey;

/* key for finding the localized title of the "Search" view */
extern NSString *const SearchViewControllerTitleKey;

/* key for finding the localized title of the "Status" view */
extern NSString *const StatusViewTitleKey;

/* key for finding the localized title of the "Settings" view */
extern NSString *const SettingsViewTitleKey;

/* key for finding the localized title of the compose view */
extern NSString *const ComposeViewTitleKey;

/* key for finding the localized value for the word "characters" */
extern NSString *const CharactersLabelKey;

/* key for finding the localized value for the word "dismiss" */
extern NSString *const DismissKey;

/* key for finding the localized value for the word "Loading..." */
extern NSString *const LoadingKey;

/* key for finding the localized value for the string "Add to Favorites" */
extern NSString *const AddToFavoritesKey;

/* key for finding the localized value for the string "Enter a Twitter ID" */
extern NSString *const EnterTwitterIDKey;

/* key for finding the localized value for the word "Cancel" */
extern NSString *const CancelKey;

/* key for finding the localized value for the word "OK" */
extern NSString *const OKKey;

/* key for finding the localized value for the string "Twitter ID" */
extern NSString *const TwitterIDKey;

/*
 * Keys for finding localized alert messages
 */

/* key for finding the localized button title for the word "Success!" */
extern NSString *const SuccessTitleKey;

/* key for finding the localized button title for the update failed alert */
extern NSString *const UpdateFailedTitleKey;

/* key for finding the localized message for the update failed alert */
extern NSString *const UpdateFailedMessageKey;

/* key for finding the localized button title for the authorization failed alert */
extern NSString *const AuthFailedTitleKey;

/* key for finding the localized message for the authorization failed alert */
extern NSString *const AuthFailedMessageKey;

/*
 * Centrally defined Nib names to avoid misspelling
 */

/* string for the ComposeStatusViewController.xib name */
extern NSString *const ComposeStatusViewControllerNibName;

/* string for the SettingsViewController.xib name */
extern NSString *const SettingsViewControllerNibName;

/*
 * Cell reuse identifiers
 */

/* string for the title cell reuse identifier on the StatusViewController */
extern NSString *const TitleCellReuseIdentifier;

/* string for the status cell reuse identifier on the StatusViewController */
extern NSString *const StatusCellReuseIdentifier;

/*
 * Keys for NSUserDefaults lookups
 */

/* string for identifying a Tweet in NSUserDefaults */
extern NSString *const TweetContentKey;

/* string for identifying a username in NSUserDefaults */
extern NSString *const UsernameKey;

/* string for identifying the AuthData value in NSUserDefaults */
extern NSString *const AuthDataKey;

/*
 * OAUTH constants
 */

extern NSString *const kOAuthConsumerKey;
extern NSString *const kOAuthConsumerSecret;