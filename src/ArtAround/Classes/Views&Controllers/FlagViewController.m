//
//  FlagViewController.m
//  ArtAround
//
//  Created by Brian Singer on 3/11/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "FlagViewController.h"

@interface FlagViewController ()

@end

@implementation FlagViewController
@synthesize delegate;
@synthesize flagDescriptionTextview;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setFlagDescriptionTextview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.flagDescriptionTextview becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate flagViewControllerPressedCancel];;
}

- (IBAction)submitButtonPressed:(id)sender {
    [self.delegate flagViewControllerPressedSubmit:self];    
}

@end
