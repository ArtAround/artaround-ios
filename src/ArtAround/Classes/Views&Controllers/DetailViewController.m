//
//  DetailViewController.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "DetailViewController.h"
#import "Art.h"
#import "Category.h"
#import "Neighborhood.h"
#import "DetailView.h"
#import "ArtAnnotation.h"
#import "Utilities.h"

@interface DetailViewController (private)
- (void)updateMapFrame;
@end

@implementation DetailViewController
@synthesize art = _art, detailView = _detailView;

- (id)init
{
	self = [super init];
    if (self) {
		
		//setup the detail view
		DetailView *aDetailView = [[DetailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
		[self setDetailView:aDetailView];
		[self.view addSubview:self.detailView];
		[self.detailView.webView setDelegate:self];
		[self.detailView.mapView setDelegate:self];
		[aDetailView release];

    }
    return self;
}

- (void)setArt:(Art *)art
{
	//assign the art
	_art = art;
	
	//setup the template
	NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"DetailView" ofType:@"html"];
	NSString *template = [[NSMutableString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL] retain];
	NSString *html = [NSString stringWithFormat:template, _art.title, _art.artist, [_art.year stringValue], _art.category.title, _art.neighborhood.title, [_art.ward stringValue], _art.locationDescription];
	
	//load the html
	[self.detailView.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	
	//add the annotation for the art
	if ([_art.latitude doubleValue] && [_art.longitude doubleValue]) {
		
		//setup the coordinate
		CLLocationCoordinate2D artLocation;
		artLocation.latitude = [art.latitude doubleValue];
		artLocation.longitude = [art.longitude doubleValue];
		
		//create an annotation, add it to the map, and store it in the array
		ArtAnnotation *annotation = [[ArtAnnotation alloc] initWithCoordinate:artLocation title:art.title subtitle:art.artist];
		[self.detailView.mapView addAnnotation:annotation];
		[annotation release];
		
	}
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[self setArt:nil];
	[self setDetailView:nil];
	[super dealloc];
}

- (void)updateMapFrame
{
	//update the map frame
	NSString *yOffset = [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"mapPos();"];
	CGRect mapFrame = self.detailView.mapView.frame;
	[self.detailView.mapView setFrame:CGRectMake(mapFrame.origin.x, [yOffset floatValue] + 5.0f, mapFrame.size.width, mapFrame.size.height)];
	[self.detailView.mapView setAlpha:1.0f];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//update the map frame
	[self updateMapFrame];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//update the map frame
	[self updateMapFrame];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	DebugLog(@"detailController webview error:", error);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	[Utilities zoomToFitMapAnnotations:mapView];
}

@end
