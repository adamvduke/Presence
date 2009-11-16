//
//  DetailViewController.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"


@interface DetailViewController : UIViewController {
	IBOutlet UILabel *nameLabel;
	//IBOutlet UILabel *statusLabel;
	IBOutlet UITextView *textView;
	IBOutlet UIImageView *detailImage;
	Person *person;
}

@property (retain) Person *person;
@end
