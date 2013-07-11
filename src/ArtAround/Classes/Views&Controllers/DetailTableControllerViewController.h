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

#define _kAddImageActionSheet 100
#define _kShareActionSheet 101
#define _kFlagActionSheet 102
#define _kLocationActionSheet 103
#define _kUserAddedImageTagBase 1000
#define _kAddImageTagBase 2000
#define _kAddImageButtonTag 3333

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

@interface DetailTableControllerViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, PhotoImageViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, FlickrNameViewControllerDelegate, SearchTableViewDelegate, UIScrollViewDelegate, ArtLocationSelectionViewViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FlagViewControllerDelegate, UINavigationControllerDelegate>
{
    int                     _addedImageCount;
    BOOL                    _inEditMode, _usingPhotoGeotag;
    UIAlertView*            _loadingAlertView;
    NSMutableArray*         _userAddedImages, *_imageButtons;
    NSMutableDictionary*    _newCommentDictionary, *_newArtDictionary;
    UIPickerView*           _datePicker;
    UIToolbar*              _dateToolbar;
    UIBarButtonItem*        _dateDoneButton;
    NSDateFormatter*        _yearFormatter;
    MKMapView*              _mapView;
    NSString*               _yearString;
    CLLocation*             _selectedLocation;
    
    //inputs
    UIScrollView*           _photosScrollView;
    UITextField*            _artistTextField, *_titleTextField, *_urlTextField;
    UIButton*               _locationButton, *_categoryButton, *_dateButton, *_editButton, *_cancelEditButton, *_submitEditButton;
    UIView*                 _footerView;
    UITextView*             _descriptionTextView, *_locationDescriptionTextView;
    
    Art*                    _art;
}

@property (nonatomic, retain) CLLocation *currentLocation;

- (id)initWithStyle:(UITableViewStyle)style art:(Art*)thisArt;


@end
