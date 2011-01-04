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

@class User;
@class ListViewController;

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
	User *user;
	NSIndexPath *indexPathInTableView;
	id <IconDownloaderDelegate> delegate;

	NSMutableData *activeDownload;
	NSURLConnection *imageConnection;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate

- (void)imageDidLoad:(NSIndexPath *)indexPath;

@end