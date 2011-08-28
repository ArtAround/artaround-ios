//
//  DetailView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "DetailView.h"

@implementation DetailView
@synthesize webView = webView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		UIWebView *aWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
		[aWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[aWebView setBackgroundColor:[UIColor colorWithRed:111.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
		[self setWebView:aWebView];
		[self addSubview:self.webView];
		[aWebView release];
    }
    return self;
}

- (void)dealloc
{
	[self setWebView:nil];
	[super dealloc];
}

@end
