//
//  Person.h
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 Adam Duke. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject 
{
	// Twitter user name or user id
	NSString *userName;
	
	// Twitter display name
	NSString *displayName;
	
	// URL for the user's avatar
	NSString *imageUrlString;
	
	// List of the user's status updates
	NSArray *statusUpdates;
	
	// Instance of the image created from imageUrlString
	UIImage *image;
}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *imageUrlString;
@property (nonatomic, retain) NSArray *statusUpdates;
@property (nonatomic, retain) UIImage *image;

// Returns a Person object initialized with an NSDictionary of information retrieved 
// using the TwitterHelper, for a particular user name
- (Person *) initPersonWithInfo:(NSDictionary *)userInfo userName:(NSString *)userName;

// Returns a boolean value indicating that the a person object has all of the necessary data
+ (BOOL)isValid:(Person *)person;

@end
