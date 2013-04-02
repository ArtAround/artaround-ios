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
#import "ArtParser.h"

@interface AddDetailViewController (private)
- (NSString *)yearString;
- (NSString *)category;
- (NSString *)artName;
- (NSString *)artistName;
- (BOOL)validateFieldsReadyToSubmit;
- (void)artUploadCompleted:(NSDictionary*)responseDict;
- (void)artUploadFailed:(NSDictionary*)responseDict;
- (void)photoUploadCompleted:(NSDictionary*)responseDict;
- (void)photoUploadFailed:(NSDictionary*)responseDict;
@end

@implementation AddDetailViewController

@synthesize currentLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _addedImageCount = 0;
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
    if (_newArtDictionary) {
        _newArtDictionary = nil, [_newArtDictionary release];
    }
    _newArtDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:aTitle, @"title", aCat, @"category", self.currentLocation, @"location[]", nil];
    
    //get the year if it exists
    if ([self yearString] && [[self yearString] length] > 0)
        [_newArtDictionary setObject:[self yearString] forKey:@"year"];
    
    //get the artist if it exists
    if ([self artistName] && [[self artistName] length] > 0)
        [_newArtDictionary setObject:[self artistName] forKey:@"artist"];

    
    //call the submit request
    [[AAAPIManager instance] submitArt:_newArtDictionary withTarget:self callback:@selector(artUploadCompleted:) failCallback:@selector(artUploadFailed:)];
    
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

- (void)userAddedImage:(UIImage*)image
{
    //increment the number of new images
    _addedImageCount += 1;
    
    //reload the images to show the new image
    [self setupImages];
    
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

#pragma mark - Upload Method Callbacks

- (void)artUploadCompleted:(NSDictionary*)responseDict
{
    if ([responseDict objectForKey:@"success"]) {
        
        //parse new art and update this controller instance's art
        [_newArtDictionary setObject:[responseDict objectForKey:@"success"] forKey:@"slug"];
        [[AAAPIManager managedObjectContext] lock];
        self.art = [ArtParser artForDict:_newArtDictionary inContext:[AAAPIManager managedObjectContext]];
        [[AAAPIManager managedObjectContext] unlock];

        //merge context
        [[AAAPIManager instance] performSelectorOnMainThread:@selector(mergeChanges:) withObject:[NSNotification notificationWithName:NSManagedObjectContextDidSaveNotification object:[AAAPIManager managedObjectContext]] waitUntilDone:YES];
    }
    else {
        [self artUploadFailed:responseDict];
        return;
    }
    
    
    //if there are user added images upload them
    if (_userAddedImages.count > 0) {
        for (UIImage *thisImage in _userAddedImages) {
            [[AAAPIManager instance] uploadImage:thisImage forSlug:self.art.slug withTarget:self callback:@selector(photoUploadCompleted:) failCallback:@selector(photoUploadFailed:)];
        }
    }
    else {
        
    }
    
}

- (void)artUploadFailed:(NSDictionary*)responseDict
{

}

- (void)photoUploadCompleted:(NSDictionary*)responseDict
{
    if ([responseDict objectForKey:@"slug"]) {
        
        //parse the art object returned and update this controller instance's art
        [[AAAPIManager managedObjectContext] lock];
        self.art = [ArtParser artForDict:responseDict inContext:[AAAPIManager managedObjectContext]];
        [[AAAPIManager managedObjectContext] unlock];
        
        //merge context
        [[AAAPIManager instance] performSelectorOnMainThread:@selector(mergeChanges:) withObject:[NSNotification notificationWithName:NSManagedObjectContextDidSaveNotification object:[AAAPIManager managedObjectContext]] waitUntilDone:YES];
    }
    else {
        [self photoUploadFailed:responseDict];
        return;
    }
    
    _addedImageCount -= 1;
}

- (void)photoUploadFailed:(NSDictionary*)responseDict
{
    _addedImageCount -= 1;    
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
    
    //url location
	NSString *url = [[request URL] absoluteString];
	
	//video play link
	if ([url rangeOfString:@"artaround://addImageButtonTapped"].location != NSNotFound) {
        
        UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Upload Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"Camera roll", nil];
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
