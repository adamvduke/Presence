//
//  TwitterHelper.m
//  Presence
//
#import "PresenceContants.h"
#import "TwitterHelper.h"
#import "JSON.h"

@implementation TwitterHelper

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

+ (id)fetchJSONValueForURL:(NSURL *)url
{
    NSString *jsonString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    id jsonValue = [jsonString JSONValue];
    
	[jsonString release];
    
    return jsonValue;
}

+ (NSDictionary *)fetchInfoForUsername:(NSString *)username
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/users/show/%@.json", [self twitterHostname], username];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

+ (NSArray *)fetchTimelineForUsername:(NSString *)username
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/statuses/user_timeline/%@.json", [self twitterHostname], username];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

+ (NSArray *)fetchFriendsForUsername:(NSString *)username
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/statuses/friends/%@.json", [self twitterHostname], username];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

+ (NSArray *)fetchPublicTimeline
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/statuses/public_timeline.json", [self twitterHostname]];
	NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

+ (NSMutableArray *)fetchFollowingIdsForUsername:(NSString *)username
{
	NSString *urlString = [NSString stringWithFormat:@"http://%@/friends/ids/%@.json", [self twitterHostname], username];
    NSURL *url = [NSURL URLWithString:urlString];
	NSArray *idsArray = [self fetchJSONValueForURL:url];
	NSMutableArray *stringIdsArray = [[[NSMutableArray alloc] init]autorelease];
	
	// turn the id's into strings
	for (NSDecimalNumber *decimalID in idsArray){
		NSString *anID = [NSString stringWithFormat:@"%@", decimalID];
		[stringIdsArray addObject:anID];
	}
    return stringIdsArray;
}

+ (NSDictionary *)fetchSearchResultsForQuery:(NSString *)query
{
    // Sanitize the query string.
	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@", query];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONValueForURL:url];
}

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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@%@/statuses/update.json", username, password, [self twitterHostname]]];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
	// We should probably be parsing the data returned by this call, for now just check the error.
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    return (error == nil);
}

@end
