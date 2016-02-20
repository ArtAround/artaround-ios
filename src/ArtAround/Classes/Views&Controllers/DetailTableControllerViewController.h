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
#import "AddCommentViewController.h"
#import "FBConnect.h"
#import "ArtAroundAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "Website_ViewController.h"
#import "KILabel.h"

@class Art;

#define _kAddImageActionSheet 100
#define _kShareActionSheet 101
#define _kFlagActionSheet 102
#define _kLocationActionSheet 103
#define _kUserAddedImageTagBase 1000
#define _kAddImageTagBase 2000
#define _kAddImageButtonTag 3333
#define kHorizontalPadding 10.0f

typedef enum AAShareType {
	AAShareTypeEmail = 0,
    AAShareTypeTwitter = 1,
	AAShareTypeFacebook = 2
} AAShareType;

typedef enum _ArtDetailRow {
    ArtDetailRowPhotos = 0,
    ArtDetailRowBuffer = 1,
    ArtDetailRowTitle = 2,
    ArtDetailRowArtist = 3,
    ArtDetailRowYear = 4,
    ArtDetailRowCategory = 5,
    ArtDetailRowTag = 6,
    ArtDetailRowLink = 7,
    ArtDetailRowLocationType = 8,
    ArtDetailRowCommissioned = 9,
    ArtDetailRowDescription = 10,
    ArtDetailRowLocationDescription = 11,
    ArtDetailRowLocationMap = 12,
    ArtDetailRowComments = 13,
    ArtDetailRowAddComment = 14

} ArtDetailRow;

@interface DetailTableControllerViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, PhotoImageViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, FlickrNameViewControllerDelegate, SearchTableViewDelegate, UIScrollViewDelegate, ArtLocationSelectionViewViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FlagViewControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, AddCommentViewControllerDelegate, MFMailComposeViewControllerDelegate, FBDialogDelegate>
{
    int                     _addedImageCount;
    BOOL                    _inEditMode, _usingPhotoGeotag;
    UIAlertView*            _loadingAlertView;
    NSMutableArray*         _userAddedImages, *_imageButtons;
    NSMutableDictionary*    _newArtDictionary;
    UIPickerView*           _datePicker;
    UIToolbar*              _dateToolbar;
    UIBarButtonItem*        _dateDoneButton;
    NSDateFormatter*        _yearFormatter;
    MKMapView*              _mapView;
    NSString*               _yearString, *_locationString;
    CLLocation*             _selectedLocation;
    Facebook*               _facebook;
    ArtAroundAppDelegate*   _appDelegate;
    
    //inputs
    UIScrollView*           _photosScrollView;
    UITextField*            _artistTextField, *_titleTextField, *_urlTextField;
    UIButton*               _locationButton, *_categoryButton, *_dateButton, *_editButton, *_cancelEditButton, *_submitEditButton, *_textDoneButton, *_favoriteButton, *_flagButton;
    UIBarButtonItem         *_doneButton;
    UIView*                 _footerView;
    UITextView*             _descriptionTextView, *_locationDescriptionTextView;
    
    Art*                    _art;
    NSString*               _url;
    NSString*               string1;
    UITextView *textV;
    UILabel *slogan;
    UIButton *website;
}

@property (nonatomic, retain) CLLocation *currentLocation;

- (id)initWithStyle:(UITableViewStyle)style art:(Art*)thisArt;


@end

