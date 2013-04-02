//
//  DetailView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "DetailView.h"



@implementation DetailView
@synthesize tableView = _tableView, mapView = _mapView, photosScrollView = _photosScrollView, rightButton = _rightButton, bottomToolbar = _bottomToolbar, leftButton = _leftButton, flagButton = _flagButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[self setBackgroundColor:[UIColor darkGrayColor]];

        
        //setup the tableView
        UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        [aTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, _kSubmitButtonBarHeight, 0.0f)];
        [aTableView setScrollIndicatorInsets:UIEdgeInsetsMake(0.0f, 0.0f, _kSubmitButtonBarHeight, 0.0f)];
        [aTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [aTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[aTableView setBackgroundColor:[UIColor colorWithRed:(82.0/255.0) green:(74.0/255.0) blue:(75.0/255.0) alpha:1.0]];
        [self setTableView:aTableView];
        [self addSubview:self.tableView];
        [aTableView release];
        
        
        //setup the submit button bar
        UIToolbar *aToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - _kSubmitButtonBarHeight, frame.size.width, _kSubmitButtonBarHeight)];
        [self setBottomToolbar:aToolbar];
        [aToolbar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [aToolbar setBarStyle:UIBarStyleDefault];
        [aToolbar setBackgroundColor:[UIColor clearColor]];
        [self addSubview:aToolbar];
        [aToolbar release];
        
        [self setEditMode:NO withCancel:NO];
        
		//setup the map view
		MKMapView *aMap = [[MKMapView alloc] initWithFrame:CGRectMake(_kMapPadding, 0.0f, frame.size.width - (_kMapPadding * 2), _kMapHeight)];
		[aMap setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[aMap setShowsUserLocation:YES];
		[self setMapView:aMap];
		[aMap release];
		
		//setup the images scroll view
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, _kPhotoScrollerHeight)];
		[scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        [scrollView setBackgroundColor:[UIColor colorWithRed:111.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
		[scrollView setShowsVerticalScrollIndicator:NO];
		[scrollView setShowsHorizontalScrollIndicator:NO];
		[self setPhotosScrollView:scrollView];
		[scrollView release];
		
		
    }
    return self;
}

- (void) setEditMode:(BOOL)editMode withCancel:(BOOL)withCancel
{
    for (UIView *thisView in self.bottomToolbar.subviews) {
        [thisView removeFromSuperview];
    }
    
    UIView *seperator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.bottomToolbar.frame.size.height)];
    seperator1.center = CGPointMake(self.bottomToolbar.center.x, seperator1.center.y);
    seperator1.backgroundColor = [UIColor grayColor];
    seperator1.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    UIView *seperator2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.bottomToolbar.frame.size.height)];
    seperator2.center = CGPointMake(self.bottomToolbar.center.x, seperator2.center.y);
    seperator2.backgroundColor = [UIColor grayColor];
    seperator2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    if (editMode) {
        
        //setup the submit button
        UIButton *rButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rButton setFrame:CGRectMake(0, 0, self.bottomToolbar.frame.size.width, self.bottomToolbar.frame.size.height)];
        [rButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [rButton setBackgroundColor:[UIColor colorWithRed:(58.0/255.0) green:(54.0/255.0) blue:(53.0/255.0) alpha:0.9]];
        rButton.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16.0];
        [rButton setTitleColor:[UIColor colorWithRed:(196.0/255.0) green:(199.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateNormal];
        [rButton setTitleColor:[UIColor colorWithRed:(170.0/255.0) green:(173.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateHighlighted];
        [rButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
        [self setRightButton:rButton];
        
       
        
        if (withCancel) {
            UIButton *lButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [lButton setFrame:CGRectMake(0, 0, self.bottomToolbar.frame.size.width / 2.0, self.bottomToolbar.frame.size.height)];
            [rButton setFrame:CGRectMake(lButton.frame.size.width, 0, self.bottomToolbar.frame.size.width / 2.0, self.bottomToolbar.frame.size.height)];
            [rButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [lButton setBackgroundColor:[UIColor colorWithRed:(58.0/255.0) green:(54.0/255.0) blue:(53.0/255.0) alpha:0.9]];
            [lButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight];
            lButton.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16.0];
            [lButton setTitleColor:[UIColor colorWithRed:(196.0/255.0) green:(199.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateNormal];
            [lButton setTitleColor:[UIColor colorWithRed:(170.0/255.0) green:(173.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateHighlighted];
            [lButton setTitle:@"CANCEL" forState:UIControlStateNormal];
            [self setLeftButton:lButton];
            [self.bottomToolbar addSubview:lButton];
            [self.bottomToolbar addSubview:rButton];
            [self.bottomToolbar addSubview:seperator1];
            
        }
        else {
            [self.bottomToolbar addSubview:rButton];
        }
        
    }
    else {
        //fav button
        UIButton *lButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [lButton setFrame:CGRectMake(0, 0, 45, self.bottomToolbar.frame.size.height)];
        [lButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin];
        [lButton setBackgroundColor:[UIColor colorWithRed:(58.0/255.0) green:(54.0/255.0) blue:(53.0/255.0) alpha:0.9]];
        [lButton setImage:[UIImage imageNamed:@"favoriteItIcon_plus.png"] forState:UIControlStateNormal];
        [lButton setImage:[UIImage imageNamed:@"favoriteItIcon_minus.png"] forState:UIControlStateSelected];
        
        //setup the submit button
        UIButton *rButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rButton setFrame:CGRectMake(lButton.frame.size.width, 0, self.bottomToolbar.frame.size.width - (lButton.frame.size.width * 2), self.bottomToolbar.frame.size.height)];
        [rButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [rButton setBackgroundColor:[UIColor colorWithRed:(58.0/255.0) green:(54.0/255.0) blue:(53.0/255.0) alpha:0.9]];
        rButton.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16.0];
        [rButton setTitleColor:[UIColor colorWithRed:(170.0/255.0) green:(173.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateHighlighted];        
        [rButton setTitleColor:[UIColor colorWithRed:(196.0/255.0) green:(199.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateNormal];
        [rButton setTitle:@"EDIT" forState:UIControlStateNormal];
        
        //flag button
        UIButton *aFlagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [aFlagButton setFrame:CGRectMake(rButton.frame.size.width + rButton.frame.origin.x, 0, 45, self.bottomToolbar.frame.size.height)];
        [aFlagButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
        [aFlagButton setBackgroundColor:[UIColor colorWithRed:(58.0/255.0) green:(54.0/255.0) blue:(53.0/255.0) alpha:0.9]];
        [aFlagButton setImage:[UIImage imageNamed:@"flagIcon.png"] forState:UIControlStateNormal];
        [aFlagButton setImage:[UIImage imageNamed:@"flagIcon.png"] forState:UIControlStateSelected];
        
        seperator1.center = CGPointMake(lButton.frame.size.width, seperator1.center.y);
        seperator2.center = CGPointMake(rButton.frame.size.width + rButton.frame.origin.x, seperator2.center.y);
        
        [self.bottomToolbar addSubview:lButton];
        [self.bottomToolbar addSubview:rButton];
        [self.bottomToolbar addSubview:aFlagButton];
        [self.bottomToolbar addSubview:seperator1];
        [self.bottomToolbar addSubview:seperator2];
        [self setLeftButton:lButton];
        [self setRightButton:rButton];
        [self setFlagButton:aFlagButton];
    }
    
}

- (void)dealloc
{
	[self setMapView:nil];
	[self setPhotosScrollView:nil];
	[super dealloc];
}

@end
