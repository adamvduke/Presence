//
//  PresenceContants.m
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "PresenceContants.h"

/*
 Keys for finding localizable strings 
 */

// key for finding the localized title of the list view
NSString *const ListViewControllerTitleKey = @"FollowingKey";

// key for finding the localized title of the favorites view
NSString *const FavoritesViewControllerTitleKey = @"FavoritesKey";

// key for finding the localized title of the search view
NSString *const SearchViewControllerTitleKey = @"SearchKey";

// key for finding the localized title of the status view
NSString *const StatusViewTitleKey = @"TweetsKey";

// key for finding the localized title of the settings view
NSString *const SettingsViewTitleKey = @"SettingsKey";

// key for finding the localized title of the compose view
NSString *const ComposeViewTitleKey = @"ComposeKey";

// key for finding the localized value for the word "characters"
NSString *const CharactersLabelKey = @"CharactersLabelKey";

// key for finding the localized value for the word "dismiss"
NSString *const DismissKey = @"DismissKey";

// key for finding the localized value for the word "Loading..."
NSString *const LoadingKey = @"LoadingKey";


/*
 Keys for finding localized alert messages
 */
// key for finding the localized button title for the word "Success!"
NSString *const SuccessTitleKey = @"SuccessTitleKey";

// key for finding the localized button title for the update failed alert
NSString *const UpdateFailedTitleKey = @"UpdateFailedTitleKey";

// key for finding the localized message for the update failed alert
NSString *const UpdateFailedMessageKey = @"UpdateFailedMessageKey";

/*
 Centrally defined strings to avoid misspelling
 */

// string for the ComposeStatusViewController.xib name
NSString *const ComposeStatusViewControllerNibName = @"ComposeStatusViewController";

// string for the SettingsViewController.xib name
NSString *const SettingsViewControllerNibName = @"SettingsViewController";

/*
 Cell reuse identifiers
 */

// string for the title cell reuse identifier on the StatusViewController
NSString *const TitleCellReuseIdentifier = @"TitleCell";

// string for the status cell reuse identifier on the StatusViewController
NSString *const StatusCellReuseIdentifier = @"StatusCell";

/*
 Keys for NSUserDefaults lookups
 */

// string for identifying a Tweet in NSUserDefaults
NSString *const TweetContentKey = @"TweetContent";

// string for identifying the Username in NSUserDefaults
NSString *const UsernameKey = @"Username";

// string for identifying the AuthData value in NSUserDefaults
NSString *const AuthDataKey = @"AuthData";


/* 
 OAUTH constants 
 */

NSString *const kOAuthConsumerKey = @"wFCsd9r6aDCTTostr1QOnA";
NSString *const kOAuthConsumerSecret = @"rDk2QXUQywdjsHjsqMhKWYP5tQc9hjJHznhaEI0BbLw";
