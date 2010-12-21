/*
 * File: IconDownloader.h
 * Abstract: Helper object for managing the downloading of a particular user's avatar.
 * As a delegate "NSURLConnectionDelegate" is downloads the avatar in the background if it does not
 * yet exist and works in conjunction with the ListViewController to manage which user needs their
 * avatar.
 *
 * A simple BOOL tracks whether or not a download is already in progress to avoid redundant
 * requests.
 *
 */

#import "IconDownloader.h"
#import "Person.h"

#define kAppIconHeight 48

@implementation IconDownloader

@synthesize person;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)dealloc
{
	[person release];
	[indexPathInTableView release];
	[activeDownload release];
	[imageConnection cancel];
	[imageConnection release];
	[super dealloc];
}

- (void)startDownload
{
	self.activeDownload = [NSMutableData data];

	/* alloc+init and start an NSURLConnection; release on completion/failure */
	NSURLConnection *conn = [[NSURLConnection alloc]
	                         initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.person.profile_image_url]] delegate:self];
	self.imageConnection = conn;
	[conn release];
}

- (void)cancelDownload
{
	[self.imageConnection cancel];
	self.imageConnection = nil;
	self.activeDownload = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	/* Clear the activeDownload property to allow later attempts */
	self.activeDownload = nil;

	/* Release the connection now that it's finished */
	self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	/* Set appIcon and clear temporary data/image */
	UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
	if(image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
	{
		CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.person.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	else
	{
		self.person.image = image;
	}

	self.activeDownload = nil;
	[image release];

	/* Release the connection now that it's finished */
	self.imageConnection = nil;

	/* call our delegate and tell it that our icon is ready for display */
	[delegate imageDidLoad:self.indexPathInTableView];
}

@end