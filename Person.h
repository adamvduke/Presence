//
//  Person.h
//  Presence
//
//  Created by Adam Duke on 11/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject {

	NSString *personName;
	NSString *imageName;
	NSString *personStatus;
}

@property (retain) NSString *imageName;
@property (retain) NSString *personName;
@property (retain) NSString *personStatus;

-(id)initWithName:(NSString *)pName imageName:(NSString *)iName status:(NSString *)pStatus;
@end
