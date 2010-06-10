//
//  PresenceContants.h
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
Keys for finding localizable strings 
*/

// key for finding the localized title of the "Following" view
extern NSString *const ListViewControllerTitleKey;

// key for finding the localized title of the "Favorites" view
extern NSString *const FavoritesViewControllerTitleKey;

// key for finding the localized title of the "Search" view
extern NSString *const SearchViewControllerTitleKey;

// key for finding the localized title of the "Status" view
extern NSString *const StatusViewTitleKey;

// key for finding the localized title of the "Settings" view
extern NSString *const SettingsViewTitleKey;

// key for finding the localized value for the word "characters"
extern NSString *const CharactersLabelKey;

// key for finding the localized value for the word "username"
extern NSString *const UsernameLabelKey;

// key for finding the localized value for the word "password"
extern NSString *const PasswordLabelKey;

// key for finding the localized value for the words "live data"
extern NSString *const LiveDataLabelKey;

// key for finding the localized title of the compose view
extern NSString *const ComposeViewTitleKey;

/*
Centrally defined Nib names to avoid misspelling
*/

// string for the ComposeStatusViewController.xib name
extern NSString *const ComposeStatusViewControllerNibName;

// string for the SettingsViewController.xib name
extern NSString *const SettingsViewControllerNibName;

/*
Cell reuse identifiers
*/

// string for the title cell reuse identifier on the StatusViewController
extern NSString *const TitleCellReuseIdentifier;

// string for the status cell reuse identifier on the StatusViewController
extern NSString *const StatusCellReuseIdentifier;

/*
Keys for NSUserDefaults lookups
*/

// string for identifying a Tweet in NSUserDefaults
extern NSString *const TweetContentKey;

// string for identifying a username in NSUserDefaults
extern NSString *const UsernameKey;

// string for identifying a password in NSUserDefaults
extern NSString *const PasswordKey;

// string for identifying the liveData value in NSUserDefaults
extern NSString *const LiveDataKey;
