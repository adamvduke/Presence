//
//  PersonListViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PersonListViewController.h"
#import "DetailViewController.h"

@implementation PersonListViewController


-(void)viewButtonPressed:(id)sender{
	
	DetailViewController *detailViewController = [[DetailViewController alloc]initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	[detailViewController setTitle:@"Detail"];
	
	if ([sender tag]==100) {
		Person *personDetail = [[Person alloc]initWithName:@"ONOZ" imageName:@"ONOZ.png" status:@"ONOZ the sky is falling!"];
		[detailViewController setPerson:personDetail];
		[personDetail release];
	}
	else {
		Person *personDetail = [[Person alloc]initWithName:@"OMG" imageName:@"OMFG.png" status:@"OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!,OMG the whole world's coming to an end!"];
		[detailViewController setPerson:personDetail];
		[personDetail release];
	}

	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

-(void)displayAlertWithMessage:(NSString *)message{
	
	UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"ALERT!" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

@end
