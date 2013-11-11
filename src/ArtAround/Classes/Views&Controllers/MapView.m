//
//  MapView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "MapView.h"
#import <QuartzCore/QuartzCore.h>

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
        [filterLabel setTextAlignment:NSTextAlignmentCenter];
        [filterLabel setTextColor:[UIColor whiteColor]];
        [filterLabel setAutoresizingMask:UIViewAutoresizingNone];
        [_headerView addSubview:filterLabel];
        [self addSubview:_headerView];
		
		//initialize the share button
		UIButton *newAddArtButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[newAddArtButton setImage:[UIImage imageNamed:@"addIcon.png"] forState:UIControlStateNormal];
        [newAddArtButton setBackgroundColor:kButtonColor];
		[newAddArtButton setFrame:CGRectMake(frame.size.width - 65.0f, frame.size.height - 51.0f, 60.0f, 46.0f)];
		[newAddArtButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
        [newAddArtButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [newAddArtButton.layer setShadowOffset:CGSizeZero];
        [newAddArtButton.layer setShadowRadius:2.0f];
        [newAddArtButton.layer setShadowOpacity:0.4f];
        
		[self setAddArtButton:newAddArtButton];
		[self addSubview:self.addArtButton];


        //initialize the locate button
		UIButton *aLocateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aLocateButton setImage:[UIImage imageNamed:@"locateIcon.png"] forState:UIControlStateNormal];
        [aLocateButton setBackgroundColor:kButtonColor];
		[aLocateButton setFrame:CGRectMake(5.0f, frame.size.height - 51.0f, 60.0f, 46.0f)];
		[aLocateButton setAutoresizingMask: UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
        [aLocateButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [aLocateButton.layer setShadowOffset:CGSizeZero];
        [aLocateButton.layer setShadowRadius:2.0f];
        [aLocateButton.layer setShadowOpacity:0.4f];
        
        [self setLocateButton:aLocateButton];
		[self addSubview:self.locateButton];

        //initialize the filter button
		UIButton *aFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        float filterWidth = newAddArtButton.frame.origin.x - aLocateButton.frame.origin.x - aLocateButton.frame.size.width - 10.0f;
        [aFilterButton setBackgroundColor:kButtonColor];
		[aFilterButton setFrame:CGRectMake(70.0f, frame.size.height - 51.0f, filterWidth, 46.0f)];
        [aFilterButton setTitle:@"Filter" forState:UIControlStateNormal];
        [aFilterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
		[aFilterButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [aFilterButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [aFilterButton.layer setShadowOffset:CGSizeZero];
        [aFilterButton.layer setShadowRadius:2.0f];
        [aFilterButton.layer setShadowOpacity:0.4f];
		[aFilterButton setAdjustsImageWhenHighlighted:NO];
		[self setFilterButton:aFilterButton];
		[self addSubview:self.filterButton];
		
        
        
    }
    return self;
}


@end
