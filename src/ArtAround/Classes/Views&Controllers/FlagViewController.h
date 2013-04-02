//
//  FlagViewController.h
//  ArtAround
//
//  Created by Brian Singer on 3/11/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlagViewControllerDelegate;

@interface FlagViewController : UIViewController

@property (nonatomic, retain) id <FlagViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITextView *flagDescriptionTextview;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;


@end

@protocol FlagViewControllerDelegate

- (void)flagViewControllerPressedCancel;
- (void)flagViewControllerPressedSubmit:(id)controller;

@end
