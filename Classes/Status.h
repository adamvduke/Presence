//
//  Status.h
//  Presence
//
//  Created by Adam Duke on 8/1/10.
//  Copyright 2010 Adam Duke. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Status : NSObject {

	NSString *text;
	NSDate *createdDate;
	NSString *createrId;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSString *createrId;

@end
