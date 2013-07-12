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
@synthesize addArtButton = _addArtButton, filterButton = _filterButton, locateButton = _locateButton, headerView = _headerView;

#define kButtonColor [UIColor colorWithRed:(67.0f/255.0f) green:(67.0f/255.0f) blue:(61.0f/255.0f) alpha:1.0]

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
        self.backgroundColor = [UIColor darkGrayColor];
        
		//setup view
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		

		//initialize the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
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
        [filterLabel setAutoresizingMask:UIViewAutoresizingNone];
        [_headerView addSubview:filterLabel];
        [self addSubview:_headerView];
		
		//initialize the share button
		UIButton *newAddArtButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		[newAddArtButton setImage:[UIImage imageNamed:@"Favorite.png"] forState:UIControlStateNormal];
//		[newAddArtButton setImage:[UIImage imageNamed:@"FavoritePressed.png"] forState:UIControlStateHighlighted]; 
        [newAddArtButton setBackgroundColor:kButtonColor];
        [newAddArtButton setTitle:@"+" forState:UIControlStateNormal];
		[newAddArtButton setFrame:CGRectMake(frame.size.width - 67.0f, frame.size.height - 51.0f, 62.0f, 46.0f)];
		[newAddArtButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
		[self setAddArtButton:newAddArtButton];
		[self addSubview:self.addArtButton];


        //initialize the locate button
		UIButton *aLocateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		[aLocateButton setImage:[UIImage imageNamed:@"Locate.png"] forState:UIControlStateNormal];
//		[aLocateButton setImage:[UIImage imageNamed:@"LocatePressed.png"] forState:UIControlStateHighlighted];
        [aLocateButton setBackgroundColor:kButtonColor];
		[aLocateButton setFrame:CGRectMake(5.0f, frame.size.height - 51.0f, 62.0f, 46.0f)];
        [aLocateButton setTitle:@"o" forState:UIControlStateNormal];
		[aLocateButton setAutoresizingMask: UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
        [self setLocateButton:aLocateButton];
		[self addSubview:self.locateButton];

        //initialize the filter button
		UIButton *aFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //		[aFilterButton setImage:[UIImage imageNamed:@"Filter.png"] forState:UIControlStateNormal];
        //		[aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackground.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
        //		[aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackgroundPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateHighlighted];
        float filterWidth = newAddArtButton.frame.origin.x - aLocateButton.frame.origin.x - aLocateButton.frame.size.width - 2.0f;
        [aFilterButton setBackgroundColor:kButtonColor];
		[aFilterButton setFrame:CGRectMake(68.0f, frame.size.height - 51.0f, filterWidth, 46.0f)];
        [aFilterButton setTitle:@"Filter" forState:UIControlStateNormal];
        [aFilterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
		[aFilterButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];

		[aFilterButton setAdjustsImageWhenHighlighted:NO];
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
