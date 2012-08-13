/*  User.h
 *  Presence
 *
 *  Created by Adam Duke on 11/12/09.
 *  Copyright 2009 Adam Duke. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface User : NSObject
{
	/* Twitter API user/id */
	NSString *user_id;

	/* Twitter API user/screen_name */
	NSString *screen_name;

	/* Twitter API user/name */
	NSString *display_name;

	/* Twitter API user/location */
	NSString *display_location;

	/* Twitter API user/description */
	NSString *display_description;

	/* Twitter API user/url */
	NSString *display_url;

	/* Twitter API user/profile_image_url */
	NSString *profile_image_url;

	/* List of the user's status updates */
	NSArray *statusUpdates;

	/* Instance of the image created from profile_image_url */
	UIImage *image;
}

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *screen_name;
@property (nonatomic, strong) NSString *display_name;
@property (nonatomic, strong) NSString *display_location;
@property (nonatomic, strong) NSString *display_description;
@property (nonatomic, strong) NSString *display_url;
@property (nonatomic, strong) NSString *profile_image_url;
@property (nonatomic, strong) NSArray *statusUpdates;
@property (nonatomic, strong) UIImage *image;

/* Returns a User object initialized with an NSDictionary of information retrieved
 * using the TwitterHelper
 */
- (User *)initWithInfo:(NSDictionary *)userInfo;

/* Returns a boolean value indicating that the a user object has all of the necessary data */
- (BOOL)isValid;

@end