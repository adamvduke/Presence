//
//  DetailViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"


@implementation DetailViewController

@synthesize person;

-(void)viewWillAppear:(BOOL)animated{
	nameLabel.text = person.personName;
	textView.text = person.personStatus;
	detailImage.image = [UIImage imageNamed:person.imageName];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)dealloc{

	[person release];
	[super dealloc];
}

@end
