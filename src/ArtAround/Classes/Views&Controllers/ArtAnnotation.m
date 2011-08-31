//
//  ArtAnnotation.m
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "ArtAnnotation.h"

@implementation ArtAnnotation
@synthesize coordinate = _coordinate;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize index = _index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate title:(NSString *)theTitle subtitle:(NSString *)theSubTitle {
	if (self = [super init]) {
		[self setCoordinate:theCoordinate];
		[self setTitle:theTitle];
		[self setSubtitle:theSubTitle];
	}
	return self;
}

- (void)dealloc {
	[self setTitle:nil];
	[self setSubtitle:nil];
	[super dealloc];
}

@end
