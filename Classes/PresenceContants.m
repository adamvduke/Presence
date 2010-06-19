//
//  PresenceContants.m
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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

// key for finding the localized value for the word "username"
NSString *const UsernameLabelKey = @"UsernameLabelKey";

// key for finding the localized value for the word "password"
NSString *const PasswordLabelKey = @"PasswordLabelKey";

// key for finding the localized value for the words "live data"
NSString *const LiveDataLabelKey = @"LiveDataLabelKey";

// key for finding the localized value for the word "dismiss"
NSString *const DismissKey = @"DismissKey";

/*
 Keys for finding localized exception messages
 */

// key for finding the localized button title for the update failed alert
NSString *const UpdateFailedTitleKey = @"UpdateFailedTitleKey";

// key for finding the localized message for the update failed alert
NSString *const UpdateFailedMessageKey = @"UpdateFailedMessageKey";

// key for finding the localized button title for missing credentials alert
NSString *const MissingCredentialsTitleKey = @"MissingCrendentialsTitleKey";

// key for finding the localized message for missing credentials alert
NSString *const MissingCredentialsMessageKey = @"MissingCredentialsMessageKey";

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

// string for identifying a username in NSUserDefaults
NSString *const UsernameKey = @"Username";

// string for identifying a password in NSUserDefaults
NSString *const PasswordKey = @"Password";

// string for identifying the liveData value in NSUserDefaults
NSString *const LiveDataKey = @"LiveData";