//
//  TwitterHelper.h
//  Presence
//

#import <Foundation/Foundation.h>

// Read about Twitter's API at http://apiwiki.twitter.com/
// Read about json-framework at http://code.google.com/p/json-framework
// Read more about Rate Limiting at http://apiwiki.twitter.com/Rate-limiting

@interface TwitterHelper : NSObject 
{
	
}

// Returns a dictionary with info about the given username.
// This method is synchronous (it will block the calling thread).
+ (NSDictionary *)fetchInfoForUsername:(NSString *)username;

// Returns an array of status updates for the given username.
// This method is synchronous (it will block the calling thread).
+ (NSArray *)fetchTimelineForUsername:(NSString *)username;

// Returns the array of user id's representing the users that the given user is following
+ (NSMutableArray *)fetchFollowingIdsForScreenName:(NSString *)username;

// Returns a dictionary with info about the given username.
// This method is synchronous (it will block the calling thread).
+ (NSArray *)fetchFriendsForUsername:(NSString *)username;

// Returns YES if the status update succeeded, otherwise NO.
// This method is synchronous (it will block the calling thread).
+ (BOOL)updateStatus:(NSString *)status forUsername:(NSString *)username withPassword:(NSString *)password;

// Returns an array of the users with the most recent status updates.
// This method is synchronous (it will block the calling thread).
+ (NSArray *)fetchPublicTimeline;

// Returns status updates matching the query string.
// This method is synchronous (it will block the calling thread).
+ (NSDictionary *)fetchSearchResultsForQuery:(NSString *)query;
@end
