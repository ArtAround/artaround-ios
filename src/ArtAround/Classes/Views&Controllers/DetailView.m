//
//  DetailView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "DetailView.h"



@implementation DetailView
@synthesize tableView = _tableView, mapView = _mapView, photosScrollView = _photosScrollView, submitButton = _submitButton, bottomToolbar = _bottomToolbar, favoriteButton = _favoriteButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[self setBackgroundColor:[UIColor darkGrayColor]];

        
        //setup the tableView
        UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        [aTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, _kSubmitButtonBarHeight, 0.0f)];
        [aTableView setScrollIndicatorInsets:UIEdgeInsetsMake(0.0f, 0.0f, _kSubmitButtonBarHeight, 0.0f)];
        [aTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [aTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[aTableView setBackgroundColor:[UIColor colorWithRed:(82.0/255.0) green:(74.0/255.0) blue:(75.0/255.0) alpha:1.0]];
        [self setTableView:aTableView];
        [self addSubview:self.tableView];
        [aTableView release];
        
		//setup the favorite button
        UIButton *aFavButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [aFavButton setBackgroundImage:[UIImage imageNamed:@"FavoriteButton.png"] forState:UIControlStateNormal];
        [aFavButton setBackgroundImage:[UIImage imageNamed:@"FavoriteButtonSelected.png"] forState:UIControlStateHighlighted];
        [aFavButton setBackgroundImage:[UIImage imageNamed:@"FavoriteButtonSelected.png"] forState:UIControlStateSelected];
        [aFavButton setFrame:CGRectMake(0, 0, [UIImage imageNamed:@"FavoriteButton.png"].size.width, [UIImage imageNamed:@"FavoriteButton.png"].size.height)];
        [self setFavoriteButton:aFavButton];
        
        //setup the submit button bar and button
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [self setSubmitButton:aButton];
        UIBarButtonItem *aBarButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIToolbar *aToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - _kSubmitButtonBarHeight, frame.size.width, _kSubmitButtonBarHeight)];
        [self setBottomToolbar:aToolbar];
        [aToolbar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [aToolbar setBarStyle:UIBarStyleBlackTranslucent];
        [aToolbar setItems:[NSArray arrayWithObjects:leftSpace, aBarButton, rightSpace, nil]];
        [self addSubview:aToolbar];
        [aToolbar release];
        [aBarButton release];
        [aButton release];
        [leftSpace release];
        [rightSpace release];
        
		//setup the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(_kMapPadding, 0.0f, frame.size.width - (_kMapPadding * 2), _kMapHeight)];
		[aMap setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[aMap setShowsUserLocation:YES];
		[self setMapView:aMap];
		[aMap release];
		
		//setup the images scroll view
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, _kPhotoScrollerHeight)];
		[scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        [scrollView setBackgroundColor:[UIColor colorWithRed:111.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
		[scrollView setShowsVerticalScrollIndicator:NO];
		[scrollView setShowsHorizontalScrollIndicator:NO];
		[self setPhotosScrollView:scrollView];
		[scrollView release];
		
		
    }
    return self;
}

- (void)dealloc
{
	[self setMapView:nil];
	[self setPhotosScrollView:nil];
	[super dealloc];
}

@end
