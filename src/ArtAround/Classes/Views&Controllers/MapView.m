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
@synthesize favoritesButton = _favoritesButton, filterButton = _filterButton, locateButton = _locateButton, headerView = _headerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
        self.backgroundColor = [UIColor darkGrayColor];
        
		//setup view
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		

		//initialize the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height- 35)];
        [aMap setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin];
		[self setMap:aMap];
		[aMap release];
		
		//setup the map view
		[self.map setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[self.map setShowsUserLocation:YES];
		[self addSubview:self.map];
        
        //header view
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        _headerView.alpha = 0;
        [_headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_headerView setClipsToBounds:YES];
        
        //background image
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectInset(_headerView.frame, -5, -10)];
        [backgroundImage setImage:[UIImage imageNamed:@"FilterBackground.png"]];
        [backgroundImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_headerView addSubview:backgroundImage];
        
        //filter label 
        UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectInset(_headerView.frame, 0, 5)];
        [filterLabel setBackgroundColor:[UIColor clearColor]];
        [filterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [filterLabel setText:@"Filtered"];
        [filterLabel setTag:1];
        [filterLabel setTextAlignment:UITextAlignmentCenter];
        [filterLabel setTextColor:[UIColor whiteColor]];
        [filterLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_headerView addSubview:filterLabel];
        [self addSubview:_headerView];
		
		//initialize the share button
		UIButton *aFavoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aFavoritesButton setImage:[UIImage imageNamed:@"Favorite.png"] forState:UIControlStateNormal];
		[aFavoritesButton setImage:[UIImage imageNamed:@"FavoritePressed.png"] forState:UIControlStateHighlighted];
		[aFavoritesButton setImage:[UIImage imageNamed:@"FavoritePressed.png"] forState:UIControlStateSelected];  
        [aFavoritesButton setBackgroundColor:[UIColor darkGrayColor]];
        //[aFavoritesButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackground.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
		//[aFavoritesButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackgroundPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateHighlighted];
		[aFavoritesButton setFrame:CGRectMake(0.0f, frame.size.height - aFavoritesButton.imageView.image.size.height + 1, aFavoritesButton.imageView.image.size.width, aFavoritesButton.imageView.image.size.height)];
		[aFavoritesButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
		[self setFavoritesButton:aFavoritesButton];
		[self addSubview:self.favoritesButton];

		
		//initialize the filter button
		UIButton *aFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aFilterButton setImage:[UIImage imageNamed:@"Filter.png"] forState:UIControlStateNormal];
		[aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackground.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
		[aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackgroundPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateHighlighted];


        [aFilterButton setBackgroundColor:[UIColor darkGrayColor]];
		[aFilterButton setFrame:CGRectMake(self.favoritesButton.frame.origin.x + self.favoritesButton.frame.size.width, self.favoritesButton.frame.origin.y, aFilterButton.imageView.image.size.width, aFilterButton.imageView.image.size.height)];
		[aFilterButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];

		[aFilterButton setAdjustsImageWhenHighlighted:NO];
		[self setFilterButton:aFilterButton];
		[self addSubview:self.filterButton];
		
		//initialize the locate button
		UIButton *aLocateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aLocateButton setImage:[UIImage imageNamed:@"Locate.png"] forState:UIControlStateNormal];
		[aLocateButton setImage:[UIImage imageNamed:@"LocatePressed.png"] forState:UIControlStateHighlighted];


        [aLocateButton setBackgroundColor:[UIColor darkGrayColor]];
		[aLocateButton setFrame:CGRectMake(self.filterButton.frame.origin.x + self.filterButton.frame.size.width, self.favoritesButton.frame.origin.y, aLocateButton.imageView.image.size.width, aLocateButton.imageView.image.size.height)];
		[aLocateButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];


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
