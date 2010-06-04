//
//  PersonListViewController.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController {
	
	// mutable array of people
	NSMutableArray *people;
	
	// operation queue for UI threading
	NSOperationQueue *queue;
	
	// activity indicator for animation during data access
	UIActivityIndicatorView	*spinner;
}


@property (retain) NSMutableArray *people;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) UIActivityIndicatorView	*spinner;

@end
