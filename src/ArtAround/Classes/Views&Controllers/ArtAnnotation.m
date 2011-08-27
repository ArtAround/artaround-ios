//
//  ArtAnnotation.m
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//
//

#import "ArtAnnotation.h"

@implementation ArtAnnotation
@synthesize coordinate = _coordinate;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize index = _index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate title:(NSString *)theTitle subtitle:(NSString *)theSubTitle {
	if (self = [super init]) {
		_coordinate = theCoordinate;
		_title = [theTitle retain];
		_subtitle = [theSubTitle retain];
	}
	return self;
}

- (void)dealloc {
	[_title release];
	[_subtitle release];
	[super dealloc];
}

@end
