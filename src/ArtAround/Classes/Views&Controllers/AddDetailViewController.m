//
//  AddDetailViewController.m
//  ArtAround
//
//  Created by Brian Singer on 1/21/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "AddDetailViewController.h"
#import "DetailView.h"

@interface AddDetailViewController (private)
- (NSString *)yearString;
- (NSString *)category;
- (NSString *)artName;
- (NSString *)artistName;
@end

@implementation AddDetailViewController

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

- (void)bottomToolbarButtonTapped
{
 
    UIAlertView *todoAlert = [[UIAlertView alloc] initWithTitle:@"Submit TODO" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [todoAlert show];
    
}

#pragma mark - ArtInfo
- (NSString *)yearString
{
    return [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"getCategory();"];
}

- (NSString *)category
{
    return [self.detailView.webView stringByEvaluatingJavaScriptFromString:@"getYear();"];
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
            [self presentModalViewController:imgPicker animated:YES];
			break;
        }
		case 1:
        {
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:imgPicker animated:YES];
			break;
        }	
		default:
			break;
	}
    
    
}

@end
