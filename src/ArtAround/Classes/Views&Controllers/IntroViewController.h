//
//  IntroViewController.h
//  ArtAround
//
//  Created by Brian Singer on 7/15/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController <UIScrollViewDelegate>
{
    NSArray *_titles, *_details;
    CGSize _originalTitleSize;
}
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)closeButtonPressed:(id)sender;

@end
