/*  SA_OAuthTwitterEngine.h
 *
 *  Created by Ben Gottlieb on 24 July 2009.
 *  Copyright 2009 Stand Alone, Inc.
 *
 *  Some code and concepts taken from examples provided by
 *  Matt Gemmell, Chris Kimpton, and Isaiah Carew
 *  See ReadMe for further attributions, copyrights and license info.
 */

#import "MGTwitterEngine.h"

@class OAToken;
@class OAConsumer;
@class SA_OAuthTwitterEngine;

@protocol SA_OAuthTwitterEngineDelegate
- (void)authSucceededForEngine;
- (void)deauthorizeEngine;
@optional

/* implement these methods to store off the creds returned by Twitter
 * if you don't do this, the user will have to re-authenticate every time they run
 */
- (void)storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username;
- (NSString *)cachedTwitterOAuthDataForUsername:(NSString *)username;
- (void)twitterOAuthConnectionFailedWithData:(NSData *)data;
@end

typedef void (^RequestTokenSetCallback)();

@interface SA_OAuthTwitterEngine : MGTwitterEngine {
	NSString *_consumerSecret;
	NSString *_consumerKey;
	NSURL *_requestTokenURL;
	NSURL *_accessTokenURL;
	NSURL *_authorizeURL;
	NSString *_pin;

	RequestTokenSetCallback requestTokenSetCallback;

	@private
	OAConsumer *_consumer;
	OAToken *_requestToken;
	OAToken *_accessToken;
}

@property (nonatomic, readwrite, retain) NSString *consumerSecret, *consumerKey;

/* you shouldn't need to touch these. Just in case... */
@property (nonatomic, readwrite, retain) NSURL *requestTokenURL, *accessTokenURL, *authorizeURL;
@property (nonatomic, readonly) BOOL OAuthSetup;

+ (SA_OAuthTwitterEngine *)OAuthTwitterEngineWithDelegate:(NSObject *)delegate;
- (SA_OAuthTwitterEngine *)initOAuthWithDelegate:(NSObject *)delegate;
- (BOOL)isAuthorized;
- (void)requestAccessToken;
- (void)requestRequestTokenWithCallback:(RequestTokenSetCallback)callback;
- (void)clearAccessToken;

@property (nonatomic, readwrite, retain)  NSString *pin;
@property (nonatomic, readonly) NSURLRequest *authorizeURLRequest;
@property (nonatomic, readonly) OAConsumer *consumer;

@end
