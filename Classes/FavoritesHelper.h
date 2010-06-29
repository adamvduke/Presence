//
//  FavoritesHelper.h
//  Presence
//
//  Created by Adam Duke on 6/20/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FavoritesHelper : NSObject {

}

// Returns the string representation of the path to
// the Favorites.plist file
+ (NSString *)favoritesPath;

// Copies the Favorites.plist file to the Documents directory
// if the file hasn't already been copied there
+ (void)moveFavoritesToDocumentsDir;

// Saves the values from the favorites array to Favorites.plist
+ (BOOL)saveFavorites:(NSArray *)favorites;

// Returns an NSMutableArray of strings where each string
// is the username of a favorite user
+ (NSMutableArray *)retrieveFavorites;

@end
