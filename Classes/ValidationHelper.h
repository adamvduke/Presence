/*  ValidationHelper.h
 *  Presence
 *
 *  Created by Adam Duke on 6/18/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

/* A static inline method to check if an id type contains any content
 * This is valid for objects that respond to the selectors length and count
 * The inline allows the compiler to actually put the method call in place
 * in the code where it is called from during compile. This should make for some
 * performance improvement, but can lead to binaries that
 * are larger than they need to be
 *
 * Credit to Will Shipley for this method
 * http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
 */
static inline BOOL IsEmpty(id thing)
{
	return thing == nil
	       || ([thing respondsToSelector:@selector(length)]
	           && [(NSData *) thing length] == 0)
	       || ([thing respondsToSelector:@selector(count)]
	           && [(NSArray *) thing count] == 0);
}