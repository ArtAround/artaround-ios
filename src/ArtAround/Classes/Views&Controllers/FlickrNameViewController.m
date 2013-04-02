//
//  FlickrNameViewController.m
//  ArtAround
//
//  Created by Brian Singer on 4/13/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "FlickrNameViewController.h"
#import "Utilities.h"

@interface FlickrNameViewController ()

@end



@implementation FlickrNameViewController

@synthesize delegate;
@synthesize flickrHandleField;
@synthesize flickrHandleImageLabel;
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self.flickrHandleField becomeFirstResponder];    

    if ([Utilities instance].flickrHandle && [Utilities instance].flickrHandle.length > 0)
        self.flickrHandleField.text = [Utilities instance].flickrHandle;
}

- (void)viewDidUnload
{
    [self setFlickrHandleField:nil];    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate flickrNameViewControllerPressedCancel:self];
}

- (IBAction)submitButtonPressed:(id)sender {
    [self.delegate flickrNameViewControllerPressedSubmit:self];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [flickrHandleImageLabel release];
    [flickrHandleField release];
    [super dealloc];
}

@end
