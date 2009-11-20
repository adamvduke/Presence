//
//  Person.h
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject {

	NSString *userName;
	NSString *displayName;
	NSString *imageUrlString;
	NSArray *statusUpdates;
	UIImage *image;
}

@property (retain) NSString *userName;
@property (retain) NSString *displayName;
@property (retain) NSString *imageUrlString;
@property (retain) NSArray *statusUpdates;
@property (retain) UIImage *image;

@end
