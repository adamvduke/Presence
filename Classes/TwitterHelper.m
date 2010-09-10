//
//  TwitterHelper.m
//  Presence
//
#import "PresenceContants.h"
#import "TwitterHelper.h"
#import "JSON.h"

@implementation TwitterHelper

/* Convenience method to determine if the application should be going after
   live data, or if it should use demo data. The value for the "LiveDataKey"
   is a boolean value set in NSUserDefaults from the settings screen
 */
+ (NSString *)twitterHostname
{
	BOOL useLiveData = [[NSUserDefaults standardUserDefaults] boolForKey:LiveDataKey];
	if (useLiveData) 
	{
		return @"twitter.com";
	}
	else
	{
		return @"adamvduke.com/development/CS193P";
	}
}

/* Downloads the actual JSON string from the give URL and uses the JSON framework's additions to NSString
   to convert the string to the appropriate type
 */
+ (id)fetchJSONValueForURL:(NSURL *)url
{
    NSString *jsonString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    id jsonValue = [jsonString JSONValue];
    
	[jsonString release];
    
    return jsonValue;
}

/* Constructs the appropriate NSURL object for the correct hostname before calling fetchJSONValueForURL
   The object returned is an NSDictionary of user information for the given user
 */
+ (NSDictionary *)fetchInfoForUsername:(NSString *)username
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/users/show/%@.json", [self twitterHostname], username];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

/* Constructs the appropriate NSURL object for the correct hostname before calling fetchJSONValueForURL
   The object returned is an NSArray of NSDictionary objects where each dictionary is a collection of key/value
   pairs relating to a particular status update for the give user
 */
+ (NSArray *)fetchTimelineForUsername:(NSString *)username
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/statuses/user_timeline/%@.json", [self twitterHostname], username];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

/* Constructs the appropriate NSURL object for the correct hostname before calling fetchJSONValueForURL
   The object returned is an NSArray of NSDictionaries where each dictionary is a collection of key/value
   pairs of information about another user that the give user "follows" on Twitter. The dictionaries are 
   of the same format as in the fetchInfoForUsername method
 */
+ (NSArray *)fetchFriendsForUsername:(NSString *)username
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/statuses/friends/%@.json", [self twitterHostname], username];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

/* Constructs the appropriate NSURL object for the correct hostname before calling fetchJSONValueForURL
   The object returned is an NSArray of NSDictionary objects where each dictionary is a collection of key/value
   pairs relating to a particular status update. The updates are from the public timeline, so whatever is happening
   on Twitter at the moment.
 */
+ (NSArray *)fetchPublicTimeline
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/statuses/public_timeline.json", [self twitterHostname]];
	NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

/* Constructs the appropriate NSURL object for the correct hostname before calling fetchJSONValueForURL
   The object returned is an NSArray of user id's that the give user "follows" on Twitter. The id's are parsed
   by the JSON framework into NSDecimalNumber objects so they are converted to NSString objects before being returned
 */
+ (NSMutableArray *)fetchFollowingIdsForScreenName:(NSString *)screenName
{
	NSString *urlString = [NSString stringWithFormat:@"http://%@/friends/ids/%@.json", [self twitterHostname], screenName];
    NSURL *url = [NSURL URLWithString:urlString];
	NSArray *idsArray = [self fetchJSONValueForURL:url];
	NSMutableArray *stringIdsArray = [[[NSMutableArray alloc] init]autorelease];
	
	// turn the id's into strings
	for (NSDecimalNumber *decimalID in idsArray){
		NSString *anID = [decimalID stringValue];
		[stringIdsArray addObject:anID];
	}
    return stringIdsArray;
}

/* Constructs the appropriate NSURL object for the correct hostname before calling fetchJSONValueForURL
   The object returned is an NSArray of NSDictionary objects where each dictionary is a collection of key/value
   pairs relating to a particular status update and the text of the updates contains the text in the given query
 */
+ (NSDictionary *)fetchSearchResultsForQuery:(NSString *)query
{
    // Sanitize the query string.
	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@", query];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

/* Posts a status update to twitter using the given name and password. The return value indicates wether the
   update was successful or not. This will not work after twitter migrates to using OAUTH exclusively and discontinues
   support for basic authorization
 */
+ (BOOL)updateStatus:(NSString *)status forUsername:(NSString *)username withPassword:(NSString *)password
{
    if (!username || !password) 
	{
        return NO;
    }
	
    NSString *post = [NSString stringWithFormat:@"status=%@", [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@%@/statuses/update.json", username, password, 
									   [self twitterHostname]]];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
	
	// This should probably be parsing the data returned by this call, for now just check the error.
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    return (error == nil);
}

@end
