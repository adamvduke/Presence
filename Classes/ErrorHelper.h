//
//  ErrorHelper.h
//  Presence
//
//  Created by Adam Duke on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ErrorHelper : NSObject {

}

+(void)displayErrorWithTitle:(NSString *)title Message:(NSString *)message CloseButtonTitle:(NSString *)closeButtonTitle;
@end
