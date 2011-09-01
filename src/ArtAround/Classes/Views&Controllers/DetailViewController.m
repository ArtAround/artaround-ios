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
#import "FlickrAPIManager.h"
#import "Photo.h"
#import "EGOImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface DetailViewController (private)
- (void)updateMapFrame;
- (void)updatePhotosScrollFrame;
- (void)setupImages;
@end

static const float _kPhotoPadding = 10.0f;
static const float _kPhotoSpacing = 15.0f;
static const float _kPhotoInitialPaddingPortait = 64.0f;
static const float _kPhotoInitialPaddingForOneLandScape = 144.0f;
static const float _kPhotoInitialPaddingForTwoLandScape = 40.0f;
static const float _kPhotoInitialPaddingForThreeLandScape = 15.0f;
static const float _kPhotoWidth = 192.0f;
static const float _kPhotoHeight = 140.0f;

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

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//add the logo to the navigation bar
	UIImage *logo = [UIImage imageNamed:@"ArtAroundLogo.png"];
	UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
	[logoView setFrame:CGRectMake(0.0f, 0.0f, logo.size.width, logo.size.height)];
	[logoView setContentMode:UIViewContentModeScaleAspectFit];
	[logoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.navigationItem setTitleView:logoView];
	[logoView release];
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
	
	//load images that we already have a source for
	[self setupImages];
	
	//get all the photo details for each photo that is missing the deets
	for (Photo *photo in [_art.photos allObjects]) {
		if (!photo.thumbnailSource || [photo.thumbnailSource isEqualToString:@""]) {
			[[FlickrAPIManager instance] downloadPhotoWithID:photo.flickrID target:self callback:@selector(setupImages)];
		}
	}
	
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

- (void)setupImages
{
	//loop through all the images and add an image view if it doesn't exist yet
	//update the url for each image view that doesn't have one yet
	//this method may be called multiple times as the flickr api returns info on each photo
	EGOImageView *prevView = nil;
	int totalPhotos = [_art.photos count];
	int photoCount = 0;
	for (Photo *photo in _art.photos) {
		
		//adjust the image view y offset
		float prevOffset = _kPhotoPadding;
		if (prevView) {
			
			//adjust offset based on the previous frame
			prevOffset = prevView.frame.origin.x + prevView.frame.size.width + _kPhotoSpacing;
			
		} else {
			
			//adjust the initial offset based on the total number of photos
			//todo: this was quick and dirty - may want to come back to this and properly align from the center out instead of this hardcoded stuff
			BOOL isPortrait = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation));
			if (isPortrait) {
				prevOffset = _kPhotoInitialPaddingPortait;
			} else {
				
				switch (totalPhotos) {
					case 1:
						prevOffset = _kPhotoInitialPaddingForOneLandScape;
						break;
						
					case 2:
						prevOffset = _kPhotoInitialPaddingForTwoLandScape;
						break;
						
					case 3:
					default:
						prevOffset = _kPhotoInitialPaddingForThreeLandScape;
						break;
				}
				
			}

		}
		
		//grab existing or create new image view
		EGOImageView *imageView = (EGOImageView *)[self.detailView.photosScrollView viewWithTag:[photo.flickrID longLongValue]];
		if (!imageView) {
			imageView = [[EGOImageView alloc] initWithPlaceholderImage:nil];
			[imageView setTag:[photo.flickrID longLongValue]];
			[imageView setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
			[imageView setClipsToBounds:YES];
			[imageView setContentMode:UIViewContentModeScaleAspectFill];
			[imageView setBackgroundColor:[UIColor lightGrayColor]];
			[imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
			[imageView.layer setBorderWidth:6.0f];
			[self.detailView.photosScrollView addSubview:imageView];
			[imageView release];
		}
		
		//set the image url if it doesn't exist yet
		if (imageView && !imageView.imageURL) {
			[imageView setImageURL:[NSURL URLWithString:photo.smallSource]];
		}
		
		//adjust the imageView autoresizing masks when there are fewer than 3 images so that they stay centered
		if (imageView && totalPhotos < 3) {
			[imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
		}
		
		//store the previous view for reference
		//increment photo count
		prevView = imageView;
		photoCount++;
		
	}
	
	//set the content size
	if (prevView) {
		[self.detailView.photosScrollView setContentSize:CGSizeMake(prevView.frame.origin.x + prevView.frame.size.width + _kPhotoSpacing, self.detailView.photosScrollView.frame.size.height)];
	}
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[self.detailView.webView setDelegate:nil];
	[self.detailView.mapView setDelegate:nil];
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

- (void)updatePhotosScrollFrame
{
	//update the photos scroll view frame
	NSString *yOffset = [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"photosPos();"];
	CGRect photosFrame = self.detailView.photosScrollView.frame;
	[self.detailView.photosScrollView setFrame:CGRectMake(photosFrame.origin.x, [yOffset floatValue] - 5.0f, photosFrame.size.width, photosFrame.size.height)];
	[self.detailView.photosScrollView setAlpha:1.0f];
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
	//update the map and photo frames
	[self updateMapFrame];
	[self updatePhotosScrollFrame];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//update the map and photo frames
	[self updateMapFrame];
	[self updatePhotosScrollFrame];
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
