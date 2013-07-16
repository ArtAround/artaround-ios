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
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)closeButtonPressed:(id)sender;

@end
