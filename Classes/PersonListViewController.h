//
//  PersonListViewController.h
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PersonListViewController : UIViewController {
	IBOutlet UIButton *button1;
	IBOutlet UIButton *button2;
}
-(IBAction)viewButtonPressed:(id)sender;
-(void)displayAlertWithMessage:(NSString *)message;

@end
