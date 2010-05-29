//
//  PersonListViewController.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController {
	NSMutableArray *people;
	NSOperationQueue *queue;
}


@property (retain) NSMutableArray *people;
@property (nonatomic, retain) NSOperationQueue *queue;


@end
