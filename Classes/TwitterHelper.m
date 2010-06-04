//
//  TwitterHelper.m
//  Presence
//

#import "TwitterHelper.h"
#import "JSON.h"

@implementation TwitterHelper

+ (NSString *)twitterHostname
{
#if USE_TEST_SERVER
	return @"www.adamvduke.com/development/CS193P";
#else
	return @"twitter.com";
#endif
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

+(NSArray *)parseStatusUpdatesFromTimeline:(NSArray *)userTimeline{
	
	NSMutableArray *returnArray = [[[NSMutableArray alloc]init]autorelease];
	for (NSDictionary *timelineEntry in userTimeline) {
		NSString *formatString = [NSString stringWithString:[timelineEntry objectForKey:@"text"]];
		[returnArray addObject:formatString];
	}
	return returnArray;
}

+ (BOOL)updateStatus:(NSString *)status forUsername:(NSString *)username withPassword:(NSString *)password
{
    if (!username || !password) {
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

+ (NSDictionary *)fetchSearchResultsForQuery:(NSString *)query
{
    // Sanitize the query string.
	query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@", query];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [self fetchJSONValueForURL:url];
    
}

@end
