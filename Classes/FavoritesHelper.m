//
//  FavoritesHelper.m
//  Presence
//
//  Created by Adam Duke on 6/20/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import "FavoritesHelper.h"


@implementation FavoritesHelper

+(NSString *)favoritesPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *favoritesPath = [documentsPath stringByAppendingPathComponent:@"Favorites.plist"];
	return favoritesPath;
}

+(void)moveFavoritesToDocumentsDir
{
	NSString *favoritesPath = [self favoritesPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:favoritesPath])
	{
		NSString *path = [[NSBundle mainBundle]pathForResource:@"FavoriteUsers" ofType:@"plist"];
		NSArray *favoriteUsersArray = [NSArray arrayWithContentsOfFile:path];
		[favoriteUsersArray writeToFile:favoritesPath atomically:YES];
	}
}

+(BOOL)saveFavorites:(NSArray *)favorites
{
	return [favorites writeToFile:[self favoritesPath] atomically:YES];
}

+(NSMutableArray *)retrieveFavorites
{
	NSString *path = [self favoritesPath];
	NSMutableArray *favoriteUsersArray = [NSArray arrayWithContentsOfFile:path];
	return favoriteUsersArray;
}
@end
