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
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *urlField;
@property (strong, nonatomic) IBOutlet UITextView *commentView;
@property (strong, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) NSString *artSlug;
@property (strong, nonatomic) id <AddCommentViewControllerDelegate> delegate;

- (IBAction)postButtonPressed:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil artSlug:(NSString*)slug;



@end

@protocol AddCommentViewControllerDelegate
- (void) commentSubmitted;
@end