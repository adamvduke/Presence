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

	Person *person;
	NSArray *statusUpdates;
}

@property (retain) Person *person;
@property (retain) NSArray *statusUpdates;

-(id)initWithStyle:(UITableViewStyle)style person:(Person *)aPerson;

@end
