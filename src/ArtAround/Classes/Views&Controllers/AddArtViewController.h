//
//  AddArtViewController.h
//  ArtAround
//
//  Created by Brian Singer on 5/18/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "FlagViewController.h"
#import "FlickrNameViewController.h"
#import "PhotoImageView.h"
#import "SearchTableViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "ArtLocationSelectionViewViewController.h"

@class Art;

static const float _kPhotoPadding = 13.0f;
static const float _kPhotoSpacing = 15.0f;
static const float _kPhotoInitialPaddingPortait = 81.5f;
static const float _kPhotoInitialPaddingForOneLandScape = 144.0f;
static const float _kPhotoInitialPaddingForTwoLandScape = 40.0f;
static const float _kPhotoInitialPaddingForThreeLandScape = 15.0f;
static const float _kPhotoWidth = 157.0f;
static const float _kPhotoHeight = 96.5f;

#define _kAddImageActionSheet 100
#define _kShareActionSheet 101
#define _kFlagActionSheet 102
#define _kLocationActionSheet 103
#define _kUserAddedImageTagBase 1000
#define _kAddImageTagBase 2000



@interface AddArtViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, PhotoImageViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, FlickrNameViewControllerDelegate, SearchTableViewDelegate, UIScrollViewDelegate, ArtLocationSelectionViewViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate>
{
    NSUInteger              _addedImageCount, _currentYear;
    NSString*               _yearString;
    BOOL                    _usingPhotoGeotag;
    NSMutableArray*         _userAddedImages, *_imageButtons;
    NSMutableDictionary*    _newArtDictionary, *_userAddedImagesAttribution;
    UIAlertView*            _loadingAlertView;
    UIPickerView*           _datePicker;
    UIToolbar*              _dateToolbar;
    UIBarButtonItem*        _doneButton;
    CLLocation*             _imageLocation, *_selectedLocation;
}


#pragma mark - Properties
@property (nonatomic, strong) FlickrNameViewController *flickrNameController;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) Art *art;

#pragma mark - IB Outlet
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *photosScrollView;
@property (strong, nonatomic) IBOutlet UIButton *locationButton;
@property (strong, nonatomic) IBOutlet UITextField *artistTextField;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UIButton *categoryButton;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextView *locationDescriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *commissionedByButton;

- (void)userAddedImage:(UIImage*)image;
- (void)userAddedImage:(UIImage*)image withAttributionText:(NSString*)text withAttributionURL:(NSString*)url;
- (void)setupImages;
- (IBAction)postButtonPressed:(id)sender;



@end
