/*  PresenceContants.m
 *  Presence
 *
 *  Created by Adam Duke on 6/3/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "PresenceConstants.h"

/*
 * Keys for finding localizable strings
 */

/* key for finding the localized title of the list view */
NSString *const ListViewControllerTitleKey = @"FollowingKey";

/* key for finding the localized title of the favorites view */
NSString *const FavoritesViewControllerTitleKey = @"FavoritesKey";

/* key for finding the localized title of the search view */
NSString *const SearchViewControllerTitleKey = @"SearchKey";

/* key for finding the localized title of the status view */
NSString *const StatusViewTitleKey = @"TweetsKey";

/* key for finding the localized title of the settings view */
NSString *const SettingsViewTitleKey = @"SettingsKey";

/* key for finding the localized title of the compose view */
NSString *const ComposeViewTitleKey = @"ComposeKey";

/* key for finding the localized value for the word "characters" */
NSString *const CharactersLabelKey = @"CharactersLabelKey";

/* key for finding the localized value for the word "dismiss" */
NSString *const DismissKey = @"DismissKey";

/* key for finding the localized value for the word "Loading..." */
NSString *const LoadingKey = @"LoadingKey";

/* key for finding the localized value for the string "Add to Favorites" */
NSString *const AddToFavoritesKey = @"AddToFavoritesKey";

/* key for finding the localized value for the string "Enter a Twitter ID" */
NSString *const EnterTwitterIDKey = @"EnterTwitterIDKey";

/* key for finding the localized value for the word "Cancel" */
NSString *const CancelKey = @"CancelKey";

/* key for finding the localized value for the word "OK" */
NSString *const OKKey = @"OKKey";

/* key for finding the localized value for the string "Twitter ID" */
NSString *const TwitterIDKey = @"TwitterIDKey";

/*
 * Keys for finding localized alert messages
 */

/* key for finding the localized button title for the word "Success!" */
NSString *const SuccessTitleKey = @"SuccessTitleKey";

/* key for finding the localized button title for the update failed alert */
NSString *const UpdateFailedTitleKey = @"UpdateFailedTitleKey";

/* key for finding the localized message for the update failed alert */
NSString *const UpdateFailedMessageKey = @"UpdateFailedMessageKey";

/* key for finding the localized button title for the authorization failed alert */
NSString *const AuthFailedTitleKey = @"AuthorizationFailedTitleKey";

/* key for finding the localized message for the authorization failed alert */
NSString *const AuthFailedMessageKey = @"AuthorizationFailedMessageKey";

/*
 * Centrally defined strings to avoid misspelling
 */

/* string for the ComposeStatusViewController.xib name */
NSString *const ComposeStatusViewControllerNibName = @"ComposeStatusViewController";

/* string for the SettingsViewController.xib name */
NSString *const SettingsViewControllerNibName = @"SettingsViewController";

/*
 * Cell reuse identifiers
 */

/* string for the title cell reuse identifier on the StatusViewController */
NSString *const TitleCellReuseIdentifier = @"TitleCell";

/* string for the status cell reuse identifier on the StatusViewController */
NSString *const StatusCellReuseIdentifier = @"StatusCell";

/*
 * Keys for NSUserDefaults lookups
 */

/* string for identifying a Tweet in NSUserDefaults */
NSString *const TweetContentKey = @"TweetContent";

/* string for identifying the Username in NSUserDefaults */
NSString *const UsernameKey = @"Username";

/* string for identifying the AuthData value in NSUserDefaults */
NSString *const AuthDataKey = @"AuthData";

/*
 * OAUTH constants
 */

NSString *const kOAuthConsumerKey = @"Ce5gG4bUX3ziyFedSCWRrQ";
NSString *const kOAuthConsumerSecret = @"wpeuhsWP6GRJKCuy8AGSk87zQ98cnKlEhs8aO1CC34E";