//
//  AddDetailViewController.m
//  ArtAround
//
//  Created by Brian Singer on 1/21/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "AddDetailViewController.h"
#import "DetailView.h"
#import "Art.h"
#import "Category.h"
#import "Neighborhood.h"
#import "AAAPIManager.h"
#import "ItemParser.h"

@interface AddDetailViewController (private)
- (NSString *)yearString;
- (NSString *)category;
- (NSString *)artName;
- (NSString *)artistName;
- (BOOL)validateFieldsReadyToSubmit;
@end

@implementation AddDetailViewController

@synthesize currentLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


//return YES if title & category have been filled in; no otherwise
- (BOOL)validateFieldsReadyToSubmit
{
    //make sure the title and category have been selected
    if ([[self category] length] > 0 && [[self artName] length] > 0)
        return YES;
    else
        return NO;
}

//Submit button tapped
- (void)bottomToolbarButtonTapped
{
    //validate title/category field
    if (![self validateFieldsReadyToSubmit]) {
        UIAlertView *todoAlert = [[UIAlertView alloc] initWithTitle:@"Need More Info" message:@"You must enter a title and category to submit art." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [todoAlert show];
        return;
    }

    //get the title & cat
    NSString *aTitle = [self artName];
    NSString *aCat = [self category];
    
    //create the art parameters dictionary
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:aTitle, @"title", aCat, @"category", self.currentLocation, @"location[]", nil];
    
    //get the year if it exists
    if ([self yearString] && [[self yearString] length] > 0)
        [params setObject:[self yearString] forKey:@"year"];
    
    //get the artist if it exists
    if ([self artistName] && [[self artistName] length] > 0)
        [params setObject:[self artistName] forKey:@"artist"];

    
    //call the submit request
    [[AAAPIManager instance] submitArt:params withTarget:self callback:nil failCallback:nil];
    
}


//override the buildHTMLString method for Add view
- (NSString*)buildHTMLString 
{
    
    //setup the template
	NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"AddDetailView" ofType:@"html"];
	NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL];

    //get the categories
    NSMutableArray *catsArray = [[NSMutableArray alloc] initWithArray:[[[AAAPIManager instance] categories] copy]];
    
    //don't include the "all" category
    [catsArray removeObject:@"All"];

    //setup categories
    NSString *categoriesString = @"";    
    for (NSString *cat in catsArray) {
        categoriesString = [NSString stringWithFormat:@"%@<option value=\"%@\">%@</option>", categoriesString, cat, cat, nil];
    }

    //get the neighborhoods
    NSMutableArray *neighborhoodsArray = [[NSMutableArray alloc] initWithArray:[[[AAAPIManager instance] neighborhoods] copy]];
    
    //don't include the "all" category
    [neighborhoodsArray removeObject:@""];
    [neighborhoodsArray removeObject:@"All"];
    
    //setup categories
    NSString *neighborhoodsString = @"";    
    for (NSString *n in neighborhoodsArray) {
        neighborhoodsString = [NSString stringWithFormat:@"%@<option value=\"%@\">%@</option>", neighborhoodsString, n, n, nil];
    }

    
	NSString *html = [NSString stringWithFormat:template, categoriesString, neighborhoodsString, [NSString stringWithFormat:@"%f",self.currentLocation.coordinate.latitude], [NSString stringWithFormat:@"%f",self.currentLocation.coordinate.longitude], nil];
    
    return html;
}

#pragma mark - ArtInfo
- (NSString *)yearString
{
    return [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"getYear();"];
}

- (NSString *)category
{
    return [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"getCategory();"];
}

- (NSString *)artName
{
    return [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"getTitle();"];
}

- (NSString *)artistName
{
    return [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"getArtistName();"];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setRightBarButtonItem:nil];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
    
    //url location
	NSString *url = [[request URL] absoluteString];
	
	//video play link
	if ([url rangeOfString:@"artaround://addImageButtonTapped"].location != NSNotFound) {
        
        UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Upload Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"Choose from your camera roll", nil];
        [shareSheet showInView:self.view];
        [shareSheet release];
        
		return NO;
	}
    
	return YES;
}



#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
 
	//decide what the picker's source is
	switch (buttonIndex) {
			
		case 0:
        {
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imgPicker.delegate = self;
            [self presentModalViewController:imgPicker animated:YES];
			break;
        }
		case 1:
        {
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imgPicker.delegate = self;            
            [self presentModalViewController:imgPicker animated:YES];
			break;
        }	
		default:
			break;
	}
    
    
}

@end
