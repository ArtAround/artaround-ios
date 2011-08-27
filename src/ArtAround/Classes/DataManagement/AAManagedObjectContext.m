//
//  AAManagedObjectContext.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import "AAManagedObjectContext.h"

@implementation AAManagedObjectContext
@synthesize userInfo = _userInfo;

- (void)dealloc {
	if (_userInfo) {
		[_userInfo release];
	}
	[super dealloc];
}

@end
