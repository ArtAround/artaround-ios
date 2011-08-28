//
//  DetailView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "DetailView.h"

static const float _kMapHeight = 175.0f;
static const float _kMapPadding = 10.0f;

@implementation DetailView
@synthesize webView = _webView, mapView = _mapView, photosScrollView = _photosScrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		
		//setup the web view
		UIWebView *aWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
		[aWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[aWebView setBackgroundColor:[UIColor colorWithRed:111.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
		[self setWebView:aWebView];
		[self addSubview:self.webView];
		[aWebView release];
		
		//setup the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(_kMapPadding, 0.0f, frame.size.width - (_kMapPadding * 2), _kMapHeight)];
		[aMap setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[aMap setShowsUserLocation:YES];
		[aMap setAlpha:0.0f];
		[self setMapView:aMap];
		[aMap release];
		
		//setup the images scroll view
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 120.0f)];
		[scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[scrollView setAlpha:0.0f];
		[self setPhotosScrollView:scrollView];
		[scrollView release];
		
		//add the mapview and PhotosScrollView to the webview's scrollview
		for (UIView *subview in self.webView.subviews) {
			if ([subview isKindOfClass:[UIScrollView class]] || [subview isKindOfClass:NSClassFromString(@"UIScroller")]) {
				[subview addSubview:self.mapView];
				[subview addSubview:self.photosScrollView];
				break;
			}
		}
		
    }
    return self;
}

- (void)dealloc
{
	[self setWebView:nil];
	[self setMapView:nil];
	[self setPhotosScrollView:nil];
	[super dealloc];
}

@end
