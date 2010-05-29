//
//  PersonListViewController.m
//  Presence
//
//  Created by Adam Duke on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "Person.h"
#import "TwitterHelper.h"
#import "StatusViewController.h"

@implementation ListViewController

@synthesize people;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return  (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (Person *) initPersonWithInfo:(NSDictionary *)userInfo userName:(NSString *)userName {
	
	NSString *imageUrlString = [userInfo valueForKey:@"profile_image_url"];
	NSString *displayName = [userInfo valueForKey:@"screen_name"];
	
	//UIImage
	NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
	NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
	UIImage *image = [[UIImage alloc] initWithData:imageData];
	
	Person *person = [[Person alloc]init];
	person.userName = userName;
	person.displayName = displayName;
	person.imageUrlString = imageUrlString;
	person.image = image;
	[image release];
	return person;
}

-(void)loadData{
	
	NSString *path = [[NSBundle mainBundle]pathForResource:@"TwitterUsers" ofType:@"plist"];
	NSArray *userNames = [NSArray arrayWithContentsOfFile:path];
	NSMutableArray *tempArray = [[NSMutableArray alloc]init];
	for (NSString *userName in userNames) {
		
		//Get the user's information from Twitter
		NSDictionary *userInfo = [TwitterHelper fetchInfoForUsername:userName];
		if (userInfo != nil) {
			
			Person *person = [self initPersonWithInfo:userInfo userName:userName];
			[tempArray addObject:person];
			[person release];
		}
	}
	self.people = tempArray;
	[tempArray release];
}

- (id)initWithStyle:(UITableViewStyle)style {
	
	// Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	
	if (self = [super initWithStyle:style]){
		[self loadData];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Table view methods

// number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows per section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [people count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	Person *person = [people objectAtIndex:indexPath.row];
	cell.imageView.image = person.image;
    cell.textLabel.text = person.userName;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create and push another view controller.
	Person *person = [people objectAtIndex:indexPath.row];
	StatusViewController *statusViewController = [[StatusViewController alloc] initWithStyle:UITableViewStyleGrouped person:person];
	[self.navigationController pushViewController:statusViewController animated:YES];
	[statusViewController release];
}

- (void)dealloc {
    [super dealloc];
}
@end
