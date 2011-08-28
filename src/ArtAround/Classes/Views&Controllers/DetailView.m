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
@synthesize webView = _webView, mapView = _mapView;

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
		
		//initialize the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(_kMapPadding, 0.0f, frame.size.width - (_kMapPadding * 2), _kMapHeight)];
		[aMap setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[aMap setShowsUserLocation:YES];
		[aMap setAlpha:0.0f];
		[self setMapView:aMap];
		[aMap release];
		
		//add the mapview to the webview's scrollview
		for (UIView *subview in self.webView.subviews) {
			if ([subview isKindOfClass:[UIScrollView class]] || [subview isKindOfClass:NSClassFromString(@"UIScroller")]) {
				[subview addSubview:self.mapView];
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
	[super dealloc];
}

@end
