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

@end
