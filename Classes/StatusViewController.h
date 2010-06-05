//
//  StatusViewController.h
//  Presence
//
//  Created by Adam Duke on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface StatusViewController : UITableViewController {

	// the person object that this view controller will display details about
	Person *person;
	
	// operation queue for threading the UI
	NSOperationQueue *queue;
}

@property (retain) Person *person;
@property (nonatomic, retain) NSOperationQueue *queue;

// initialize an instance with a UITableViewStyle and Person object
-(id)initWithStyle:(UITableViewStyle)style person:(Person *)aPerson;

@end


