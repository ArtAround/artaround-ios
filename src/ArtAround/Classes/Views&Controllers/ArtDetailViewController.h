//
//  ArtDetailViewController.h
//  ArtAround
//
//  Created by Brian Singer on 5/18/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
//#import <MessageUI/MessageUI.h>
#import "PhotoImageView.h"

#import "FBConnect.h"
#import "FlagViewController.h"
#import "FlickrNameViewController.h"
#import "PhotoImageView.h"

@class Art;

static const float _kPhotoPadding = 5.0f;
static const float _kPhotoSpacing = 15.0f;
static const float _kPhotoInitialPaddingPortait = 64.0f;
static const float _kPhotoInitialPaddingForOneLandScape = 144.0f;
static const float _kPhotoInitialPaddingForTwoLandScape = 40.0f;
static const float _kPhotoInitialPaddingForThreeLandScape = 15.0f;
static const float _kPhotoWidth = 192.0f;
static const float _kPhotoHeight = 140.0f;

#define _kAddImageActionSheet 100
#define _kShareActionSheet 101
#define _kFlagActionSheet 102
#define _kUserAddedImageTagBase 1000



@interface ArtDetailViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, PhotoImageViewDelegate>
{
    int                    _addedImageCount;    
    NSMutableArray*        _userAddedImages;
}


#pragma mark - Properties
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, assign) Art *art;

#pragma mark - IB Outlet
@property (retain, nonatomic) IBOutlet UIScrollView *photosScrollView;
@property (retain, nonatomic) IBOutlet UIButton *locationButton;
@property (retain, nonatomic) IBOutlet UITextField *artistTextField;
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UIButton *categoryButton;
@property (retain, nonatomic) IBOutlet UIButton *eventButton;
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextView;

- (void)setArt:(Art *)art withTemplate:(NSString*)templateFileName;
- (void)setArt:(Art *)art withTemplate:(NSString*)templateFileName forceDownload:(BOOL)force;
- (void)setInEditMode:(BOOL)editMode;
- (void)bottomToolbarButtonTapped;
- (void)userAddedImage:(UIImage*)image;
- (void)setupImages;




@end
