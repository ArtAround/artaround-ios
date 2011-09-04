//
//  MapView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "MapView.h"

@implementation MapView
@synthesize map = _map;
@synthesize shareButton = _shareButton, filterButton = _filterButton, locateButton = _locateButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		//setup view
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		
		//initialize the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
		[self setMap:aMap];
		[aMap release];
		
		//setup the map view
		[self.map setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[self.map setShowsUserLocation:YES];
		[self addSubview:self.map];
		
		//initialize the share button
		UIButton *aShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aShareButton setImage:[UIImage imageNamed:@"ShareArt.png"] forState:UIControlStateNormal];
		[aShareButton setImage:[UIImage imageNamed:@"ShareArtPressed.png"] forState:UIControlStateHighlighted];
		[aShareButton setFrame:CGRectMake(0.0f, 0.0f, aShareButton.imageView.image.size.width, aShareButton.imageView.image.size.height)];
		[aShareButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
		[self setShareButton:aShareButton];
		[self addSubview:self.shareButton];
		
		//initialize the filter button
		UIButton *aFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aFilterButton setImage:[UIImage imageNamed:@"Filter.png"] forState:UIControlStateNormal];
		[aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackground.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
		[aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackgroundPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateHighlighted];
		[aFilterButton setFrame:CGRectMake(self.shareButton.frame.origin.x + self.shareButton.frame.size.width, 0.0f, aFilterButton.imageView.image.size.width, aFilterButton.imageView.image.size.height)];
		[aFilterButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[aFilterButton setAdjustsImageWhenHighlighted:NO];
		[self setFilterButton:aFilterButton];
		[self addSubview:self.filterButton];
		
		//initialize the locate button
		UIButton *aLocateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aLocateButton setImage:[UIImage imageNamed:@"Locate.png"] forState:UIControlStateNormal];
		[aLocateButton setImage:[UIImage imageNamed:@"LocatePressed.png"] forState:UIControlStateHighlighted];
		[aLocateButton setFrame:CGRectMake(self.filterButton.frame.origin.x + self.filterButton.frame.size.width, 0.0f, aLocateButton.imageView.image.size.width, aLocateButton.imageView.image.size.height)];
		[aLocateButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
		[self setLocateButton:aLocateButton];
		[self addSubview:self.locateButton];
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
