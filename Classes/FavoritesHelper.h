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

+(NSString *)favoritesPath;

+(void)moveFavoritesToDocumentsDir;

+(BOOL)saveFavorites:(NSArray *)favorites;

+(NSMutableArray *)retrieveFavorites;

@end
