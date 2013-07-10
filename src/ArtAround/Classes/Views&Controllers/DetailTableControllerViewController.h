//
//  DetailTableControllerViewController.h
//  ArtAround
//
//  Created by Brian Singer on 7/9/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoImageView.h"
#import "FlagViewController.h"
#import "FlickrNameViewController.h"
#import "SearchTableViewController.h"
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
static const float _kMapHeight = 175.0f;
static const float _kMapPadding = 11.0f;
static const float _kPhotoScrollerHeight = 150.0f;

#define _kAddImageActionSheet 100
#define _kShareActionSheet 101
#define _kFlagActionSheet 102
#define _kLocationActionSheet 103
#define _kUserAddedImageTagBase 1000
#define _kAddImageTagBase 2000

typedef enum _ArtDetailRow {
    ArtDetailRowPhotos = 0,
    ArtDetailRowTitle = 1,
    ArtDetailRowArtist = 2,
    ArtDetailRowYear = 3,
    ArtDetailRowCategory = 4,
    ArtDetailRowDescription = 5,
    ArtDetailRowLocationType = 6,
    ArtDetailRowLocationDescription = 7,
    ArtDetailRowLocationMap = 8,
    ArtDetailRowLink = 9,
    ArtDetailRowCommissioned = 10
} ArtDetailRow;

@interface DetailTableControllerViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, PhotoImageViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, FlickrNameViewControllerDelegate, SearchTableViewDelegate, UIScrollViewDelegate, ArtLocationSelectionViewViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL                    _inEditMode, _usingPhotoGeotag;
    UIAlertView*            _loadingAlertView;
    NSMutableArray*         _userAddedImages, *_imageButtons;
    NSMutableDictionary*    _newCommentDictionary;
    UIPickerView*           _datePicker;
    UIToolbar*              _dateToolbar;
    UIBarButtonItem*        _dateDoneButton;
    NSDateFormatter*        _yearFormatter;
    MKMapView*              _mapView;
    
    //inputs
    UIScrollView*           _photosScrollView;
    UITextField*            _artistTextField, *_titleTextField, *_urlTextField;
    UIButton*               _locationButton, *_categoryButton, *_dateButton;
    UITextView*             _descriptionTextView, *_locationDescriptionTextView;
    
    Art*                    _art;
}

- (id)initWithStyle:(UITableViewStyle)style art:(Art*)thisArt;


@end
