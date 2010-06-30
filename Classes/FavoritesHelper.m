//
//  FavoritesHelper.m
//  Presence
//
//  Created by Adam Duke on 6/20/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "FavoritesHelper.h"


@implementation FavoritesHelper

// Returns the string representation of the path to
// the Favorites.plist file
+ (NSString *)favoritesPath
{
	// get the path for the Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	
	// append the path component for the Favorites.plist
	NSString *favoritesPath = [documentsPath stringByAppendingPathComponent:@"Favorites.plist"];
	return favoritesPath;
}

// Copies the Favorites.plist file to the Documents directory
// if the file hasn't already been copied there
+ (void)moveFavoritesToDocumentsDir
{
	// get the path to save the favorites
	NSString *favoritesPath = [self favoritesPath];
	
	// check to see if there is already a file saved at the favoritesPath
	// if not, copy the default FavoriteUsers.plist to the favoritesPath
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:favoritesPath])
	{
		NSString *path = [[NSBundle mainBundle]pathForResource:@"FavoriteUsers" ofType:@"plist"];
		NSArray *favoriteUsersArray = [NSArray arrayWithContentsOfFile:path];
		[favoriteUsersArray writeToFile:favoritesPath atomically:YES];
	}
}

// Saves the values from the favorites array to Favorites.plist
+ (BOOL)saveFavorites:(NSArray *)favorites
{
	return [favorites writeToFile:[self favoritesPath] atomically:YES];
}

// Returns an NSMutableArray of strings where each string
// is the username of a favorite user
+ (NSMutableArray *)retrieveFavorites
{
	NSString *path = [self favoritesPath];
	NSMutableArray *favoriteUsersArray = [NSArray arrayWithContentsOfFile:path];
	return favoriteUsersArray;
}
@end
