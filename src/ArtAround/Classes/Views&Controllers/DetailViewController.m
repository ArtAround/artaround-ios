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
- (void)updateNativeFrames;
- (void)setupImages;
- (void)shareOnTwitter;
- (void)shareOnFacebook;
- (void)showFBDialog;
- (void)shareViaEmail;
- (NSString *)shareMessage;
- (NSString *)shareURL;
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
		
		//get a reference to the app delegate
		_appDelegate = (ArtAroundAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		//observe notification for facebook login
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFBDialog) name:@"fbDidLogin" object:nil];

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
	
	//add a share button
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped)];
	[self.navigationItem setRightBarButtonItem:shareButton];
	[shareButton release];
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

- (void)updateNativeFrames
{
	//update the map frame
	NSString *yOffsetMap = [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"mapPos();"];
	CGRect mapFrame = self.detailView.mapView.frame;
	[self.detailView.mapView setFrame:CGRectMake(mapFrame.origin.x, [yOffsetMap floatValue] + 5.0f, mapFrame.size.width, mapFrame.size.height)];

	//update the photos scroll view frame
	NSString *yOffsetPhotos = [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"photosPos();"];
	CGRect photosFrame = self.detailView.photosScrollView.frame;
	[self.detailView.photosScrollView setFrame:CGRectMake(photosFrame.origin.x, [yOffsetPhotos floatValue] - 5.0f, photosFrame.size.width, photosFrame.size.height)];
	
	//start animation block
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	
	//fade the everything in
	//this avoids a blank white screen blinding the user for a brief moment
	[self.detailView.mapView setAlpha:1.0f];
	[self.detailView.webView setAlpha:1.0f];
	[self.detailView.photosScrollView setAlpha:1.0f];
	
	//end animation block
    [UIView commitAnimations];
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
	[self updateNativeFrames];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//update the map and photo frames
	[self updateNativeFrames];
	
	//set a native style scroll speed
	for (UIView *subview in [webView subviews]) {
		if ([subview isKindOfClass:NSClassFromString(@"UIScroller")] || [subview isKindOfClass:NSClassFromString(@"UIScrollView")]) {
			if ([subview respondsToSelector:@selector(setDecelerationRate:)]) {
				[(UIScrollView *)subview setDecelerationRate:UIScrollViewDecelerationRateNormal];
			}
			break;
		}
	}
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

#pragma mark - Share

- (void)shareButtonTapped
{
	//show an action sheet with the various sharing types
	UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Share This Item" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
	[shareSheet showInView:self.view];
	[shareSheet release];
}

- (void)shareViaEmail
{
	if ([MFMailComposeViewController canSendMail]) {
		
		//present the mail composer
		MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
		mailController.mailComposeDelegate = self;
		[mailController setSubject:@"Art Around"];
		[mailController setMessageBody:[self shareMessage] isHTML:NO];
		[self presentModalViewController:mailController animated:YES];
		[mailController release];
		
	} else {
		
		//this device can't send email
		UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Email Error" message:@"This device is not configured to send email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[emailAlert show];
		[emailAlert release];
		
	}
}

- (void)shareOnTwitter
{
	//share on twitter in the browser
	NSString *twitterShare = [NSString stringWithFormat:@"http://twitter.com/share?text=%@", [[self shareMessage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterShare]];
}

- (void)shareOnFacebook
{
	//do we have a reference to the facebook object?
	if (!_facebook) {
		
		//get a reference to the facebook object
		_facebook = _appDelegate.facebook;
		
		//make sure the access token is properly set if we previously saved it
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		NSString *accessToken = [prefs stringForKey:@"FBAccessTokenKey"];
		NSDate *expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
		[_facebook setAccessToken:accessToken];
		[_facebook setExpirationDate:expirationDate];
		
	}
	
	//make sure we have a valid reference to the facebook object
	if (!_facebook) {
		[_appDelegate fbDidNotLogin:NO];
		return;
	}
	
	//make sure we are authorized
	if (![_facebook isSessionValid]) {
		NSArray* permissions =  [NSArray arrayWithObjects:@"publish_stream", nil];
		[_facebook authorize:permissions];
	} else {
		[self showFBDialog];
	}
}

- (void)showFBDialog
{
	//make sure we have a valid reference to the facebook object
	if (!_facebook) {
		[_appDelegate fbDidNotLogin:NO];
		return;
	}
	
	//grab the first photo
	NSString *photoURL = @"";
	if (_art.photos && [_art.photos count] > 0) {
		Photo *photo = [[_art.photos allObjects] objectAtIndex:0];
		photoURL = photo.thumbnailSource;
	}
	
	//setup the parameters with info about this art
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"Share on Facebook",  @"user_message_prompt",
								   [self shareURL], @"link",
								   photoURL, @"picture",
								   nil];
	
	//show the share dialog
	[_facebook dialog:@"feed" andParams:params andDelegate:self];
}

- (NSString *)shareMessage
{
	return [NSString stringWithFormat:@"Art Around: %@", [self shareURL]];
}

- (NSString *)shareURL
{
	return [NSString stringWithFormat:@"http://theartaround.us/arts/%@", _art.slug];
}

#pragma mark - FBDialogDelegate

- (void)dialogDidSucceed:(FBDialog*)dialog
{
	if ([dialog class] == [FBLoginDialog class]) {
		[self showFBDialog];
	}
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//decide what to do based on the button index
	switch (buttonIndex) {
			
		//share via email
		case AAShareTypeEmail:
			[self shareViaEmail];
			break;
			
		//share via twitter
		case AAShareTypeTwitter:
			[self shareOnTwitter];
			break;
			
		//share via facebook
		case AAShareTypeFacebook:
			[self shareOnFacebook];
			break;
			
		default:
			break;
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	//dismiss the mail composer
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}


@end
