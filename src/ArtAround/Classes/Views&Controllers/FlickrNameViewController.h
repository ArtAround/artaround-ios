//
//  FlickrNameViewController.h
//  ArtAround
//
//  Created by Brian Singer on 4/13/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlickrNameViewControllerDelegate;

@interface FlickrNameViewController : UIViewController

@property (nonatomic, strong) id <FlickrNameViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic) IBOutlet UITextField *flickrHandleField;
@property (strong, nonatomic) IBOutlet UITextField *attributionURLField;
@property (strong, nonatomic) IBOutlet UILabel *flickrHandleImageLabel;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;


@end

@protocol FlickrNameViewControllerDelegate

- (void)flickrNameViewControllerPressedCancel:(id)controller;
- (void)flickrNameViewControllerPressedSubmit:(id)controller;

@end
