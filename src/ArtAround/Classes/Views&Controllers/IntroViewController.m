//
//  IntroViewController.m
//  ArtAround
//
//  Created by Brian Singer on 7/15/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()
- (void) setLabelsForIndex:(int)index;
@end

@implementation IntroViewController
@synthesize pageControl;
@synthesize scrollView = _scrollView;
@synthesize titleLabel;
@synthesize detailLabel;
@synthesize closeButton;
@synthesize doneButton;

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
    
    _titles = [[NSArray alloc] initWithObjects:
               @"Welcome to ArtAround",
               @"Seek",
               @"Share",
               @"O.K. start!", nil];
    _details = [[NSArray alloc] initWithObjects:
                @"Get to know the art around you -- and let others know about it, too.",
                @"Find art by location and by category. Learn about the artist behind it.",
                @"Add art and say what you know about it so others can follow in your footseps.",
                @"People are already mapping in D.C., San Francisco, and Oakland -- check it out!", nil];
    
    for (int index = 0; index < 4; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"introImage%i.png", index]]];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setFrame:CGRectMake((index * self.scrollView.frame.size.width), 0.0f, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.scrollView addSubview:imageView];
    }
    
    [self.scrollView setContentSize:CGSizeMake((self.scrollView.frame.size.width * _titles.count), self.scrollView.frame.size.height)];
    
    [self.titleLabel setContentMode:UIViewContentModeBottomLeft];
    
    _originalTitleSize = self.titleLabel.frame.size;
    
    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:_originalTitleSize lineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.detailLabel.frame.origin.y - titleSize.height, titleSize.width, titleSize.height)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [pageControl release];
    [_scrollView release];
    [titleLabel release];
    [detailLabel release];
    [closeButton release];
    [doneButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPageControl:nil];
    [self setScrollView:nil];
    [self setTitleLabel:nil];
    [self setDetailLabel:nil];
    [self setCloseButton:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}
- (IBAction)closeButtonPressed:(id)sender {
}

- (void) setLabelsForIndex:(int)index
{
    [self.titleLabel setText:[_titles objectAtIndex:index]];
    [self.detailLabel setText:[_details objectAtIndex:index]];
    
    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:_originalTitleSize lineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.detailLabel.frame.origin.y - titleSize.height, titleSize.width, titleSize.height)];
    
    if (index == _titles.count - 1)
        self.doneButton.alpha = 1.0f;
    else
        self.doneButton.alpha = 0.0f;
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float offset = scrollView.contentOffset.x;
    int page = offset / self.scrollView.frame.size.width;
    DebugLog(@"%i", page);
    [self setLabelsForIndex:page];
    
    [self.pageControl setCurrentPage:page];
}

@end
