//
//  StatusViewController.h
//  Presence
//
//  Created by Adam Duke on 11/17/09.
//  Copyright 2009 Adam Duke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataAccessHelper.h"
@class Person;

@interface StatusViewController : UITableViewController 
{
	// the person object that this view controller will display details about
	Person *person;
	
	// operation queue for threading the UI
	NSOperationQueue *queue;
	
	// activity indicator for animation during data access
	UIActivityIndicatorView	*spinner;
	
	// DataAccessHelper to save status updates
	DataAccessHelper *dataAccessHelper;
}

@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) DataAccessHelper *dataAccessHelper;

// initialize an instance with a UITableViewStyle and Person object
- (id)initWithPerson:(Person *)aPerson dataAccessHelper:(DataAccessHelper *)accessHelper;

@end


