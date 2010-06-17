//
//  Person.h
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject 
{
	NSString *userName;
	NSString *displayName;
	NSString *imageUrlString;
	NSArray *statusUpdates;
	UIImage *image;
}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *imageUrlString;
@property (nonatomic, retain) NSArray *statusUpdates;
@property (nonatomic, retain) UIImage *image;

-(Person *) initPersonWithInfo:(NSDictionary *)userInfo userName:(NSString *)userName;

@end
