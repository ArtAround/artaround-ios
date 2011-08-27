//
//  MapView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//
//

#import "MapView.h"

@implementation MapView
@synthesize map = _map;
@synthesize filterButton = _filterButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		//initialize the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
		[self setMap:aMap];
		[aMap release];
		
		//setup the map view
		[[self map] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[[self map] setShowsUserLocation:YES];
		[self addSubview:[self map]];
		
		//initialize the filter button
		UIButton *aFilterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aFilterButton setTitle:@"Filter" forState:UIControlStateNormal];
		[aFilterButton setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 44.0f)];
		[aFilterButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[self setFilterButton:aFilterButton];
		[self addSubview:self.filterButton];
		
    }
    return self;
}

- (void)dealloc
{
	[self setMap:nil];
	[self setFilterButton:nil];
	[super dealloc];
}

@end
