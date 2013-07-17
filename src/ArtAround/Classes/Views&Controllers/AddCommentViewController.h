//
//  AddCommentViewController.h
//  ArtAround
//
//  Created by Brian Singer on 7/16/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCommentViewControllerDelegate;

@interface AddCommentViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    NSMutableDictionary*    _commentDictionary;
    UIAlertView*            _loadingAlertView;
}
@property (retain, nonatomic) IBOutlet UITextField *nameField;
@property (retain, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) IBOutlet UITextField *urlField;
@property (retain, nonatomic) IBOutlet UITextView *commentView;
@property (retain, nonatomic) IBOutlet UIButton *postButton;
@property (retain, nonatomic) NSString *artSlug;
@property (retain, nonatomic) id <AddCommentViewControllerDelegate> delegate;

- (IBAction)postButtonPressed:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil artSlug:(NSString*)slug;



@end

@protocol AddCommentViewControllerDelegate
- (void) commentSubmitted;
@end