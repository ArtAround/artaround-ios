//
//  AddCommentViewController.m
//  ArtAround
//
//  Created by Brian Singer on 7/16/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "AddCommentViewController.h"
#import "AAAPIManager.h"
#import "Utilities.h"

@interface AddCommentViewController ()
- (BOOL) findAndResignFirstResponder;
- (void)commentUploadFailed:(NSDictionary*)responseDict;
- (void)commentUploadCompleted:(NSDictionary*)responseDict;
@end

@implementation AddCommentViewController
@synthesize nameField;
@synthesize emailField;
@synthesize urlField;
@synthesize commentView;
@synthesize postButton;
@synthesize artSlug = _artSlug;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil artSlug:(NSString*)slug
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _commentDictionary = [[NSMutableDictionary alloc] init];
        _artSlug = [[NSString alloc] initWithString:slug];
    }
    return self;
}

//present the loading view
- (void)showLoadingView:(NSString*)msg
{
    //display loading alert view
    if (!_loadingAlertView) {
        _loadingAlertView = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.tag = 10;
        // Adjust the indicator so it is up a few pixels from the bottom of the alert
        indicator.center = CGPointMake(_loadingAlertView.bounds.size.width / 2, _loadingAlertView.bounds.size.height - 50);
        indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [indicator startAnimating];
        [_loadingAlertView addSubview:indicator];
        [indicator release];
    }
    
    [_loadingAlertView setTitle:msg];
    [_loadingAlertView show];
    
    
    
    //display an activity indicator view in the center of alert
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[_loadingAlertView viewWithTag:10];
    [activityView setCenter:CGPointMake(_loadingAlertView.bounds.size.width / 2, _loadingAlertView.bounds.size.height - 44)];
    [activityView setFrame:CGRectMake(roundf(activityView.frame.origin.x), roundf(activityView.frame.origin.y), activityView.frame.size.width, activityView.frame.size.height)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //setup saved field values
    if ([Utilities instance].commentName && [Utilities instance].commentName.length > 0) {
        self.nameField.text = [Utilities instance].commentName;
        [_commentDictionary setObject:[Utilities instance].commentName forKey:@"name"];
    }
    
    if ([Utilities instance].commentEmail && [Utilities instance].commentEmail.length > 0) {
        self.emailField.text = [Utilities instance].commentEmail;
        [_commentDictionary setObject:[Utilities instance].commentEmail forKey:@"email"];
    }
    
    if ([Utilities instance].commentUrl && [Utilities instance].commentUrl.length > 0) {
        self.urlField.text = [Utilities instance].commentUrl;
        [_commentDictionary setObject:[Utilities instance].commentUrl forKey:@"url"];
    }
    
    //setup back button
    UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backButtonImage.size.width + 10.0f, backButtonImage.size.height)];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton setContentMode:UIViewContentModeCenter];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [nameField release];
    [emailField release];
    [urlField release];
    [commentView release];
    [postButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setNameField:nil];
    [self setEmailField:nil];
    [self setUrlField:nil];
    [self setCommentView:nil];
    [self setPostButton:nil];
    [super viewDidUnload];
}

- (IBAction)postButtonPressed:(id)sender {
    
    [self findAndResignFirstResponder];
    
    
    if ([[_commentDictionary objectForKey:@"text"] length] > 0 && [[_commentDictionary objectForKey:@"email"] length] > 0 && [[_commentDictionary objectForKey:@"name"] length] > 0) {
        
        //check for valid email address
        BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
        NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
        NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        if (![emailTest evaluateWithObject:[_commentDictionary objectForKey:@"email"]]) {
            
            UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please use a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [emailAlert show];
            [emailAlert release];
            
            return;
        }
        
        //save field values
        [[Utilities instance] setCommentName:[_commentDictionary objectForKey:@"name"]];
        [[Utilities instance] setCommentEmail:[_commentDictionary objectForKey:@"email"]];
        if ([_commentDictionary objectForKey:@"url"] && [[_commentDictionary objectForKey:@"url"] length] > 0)
            [[Utilities instance] setCommentUrl:[_commentDictionary objectForKey:@"url"]];
        
        //upload the comment
        [[AAAPIManager instance] uploadComment:_commentDictionary forSlug:_artSlug target:self callback:@selector(commentUploadCompleted:) failCallback:@selector(commentUploadFailed:)];
        
        //show loading view
        [self showLoadingView:@"Submitting Comment\nPlease Wait..."];
        
    }
    else {
        UIAlertView *noDataAlert = [[UIAlertView alloc] initWithTitle:@"Missing Data" message:@"To submit a comment you have to enter a Name, Email Address, and a Comment" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noDataAlert show];
        [noDataAlert release];
    }
    
}

#pragma mark - Text View Delegate

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (textView == self.commentView && ![textView.text isEqualToString:@"Comment"])
        [_commentDictionary setObject:newText forKey:@"text"];
    
    //setup add art button
    if ([_commentDictionary objectForKey:@"name"] && [[_commentDictionary objectForKey:@"name"] length] > 0 && [_commentDictionary objectForKey:@"email"] && [[_commentDictionary objectForKey:@"email"] length] > 0 && [_commentDictionary objectForKey:@"text"] && [[_commentDictionary objectForKey:@"text"] length] > 0) {
        
        [self.postButton setBackgroundColor:[UIColor colorWithRed:(223.0f/255.0f) green:(73.0f/255.0f) blue:(70.0f/255.0f) alpha:1.0f]];
        self.postButton.enabled = YES;
        
    }
    else {
        [self.postButton setBackgroundColor:[UIColor colorWithWhite:0.71f alpha:1.0f]];
        self.postButton.enabled = NO;
    }
    
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView
{
    
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"Comment"]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        if (textView == self.commentView) {
            [textView setText:@"Comment"];
        }
        
        [textView setTextColor:[UIColor colorWithWhite:0.71f alpha:1.0f]];
    }
    
    
}

#pragma mark - Text Field Delegate

- (BOOL) findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    
    if (self.urlField.isFirstResponder) {
        [self.urlField resignFirstResponder];
        return YES;
    }
    else if (self.emailField.isFirstResponder) {
        [self.emailField resignFirstResponder];
        return YES;
    }
    else if (self.nameField.isFirstResponder) {
        [self.nameField resignFirstResponder];
        return YES;
    }
    
    return NO;
}

- (void) textFieldChanged:(UITextField*)textField withText:(NSString*)text
{
    
    NSString *key = @"";
    
    if (textField == self.nameField)
        key = @"name";
    else if (textField == self.emailField)
        key = @"email";
    else if (textField == self.urlField)
        key = @"url";
    
    [_commentDictionary setObject:text forKey:key];
    
    //setup add art button
    if ([_commentDictionary objectForKey:@"name"] && [[_commentDictionary objectForKey:@"name"] length] > 0 && [_commentDictionary objectForKey:@"email"] && [[_commentDictionary objectForKey:@"email"] length] > 0 && [_commentDictionary objectForKey:@"text"] && [[_commentDictionary objectForKey:@"text"] length] > 0) {
        
        [self.postButton setBackgroundColor:[UIColor colorWithRed:(223.0f/255.0f) green:(73.0f/255.0f) blue:(70.0f/255.0f) alpha:1.0f]];
        self.postButton.enabled = YES;
        
    }
    else {
        [self.postButton setBackgroundColor:[UIColor colorWithWhite:0.71f alpha:1.0f]];
        self.postButton.enabled = NO;
    }
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self findAndResignFirstResponder];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self textFieldChanged:textField withText:newText];
    return YES;
}

#pragma mark - Comment Upload Callback Methods

- (void)commentUploadCompleted:(NSDictionary*)responseDict
{
    
    //check for success
    if ([[responseDict objectForKey:@"success"] boolValue]) {
        
        //dismiss alert
        [_loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        UIAlertView *moderationComment = [[UIAlertView alloc] initWithTitle:@"Thanks for your comment! Our moderators will approve it shortly" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [moderationComment show];
        
        if (_delegate && [(id)_delegate canPerformAction:@selector(commentSubmitted) withSender:self]) {
            [_delegate commentSubmitted];
        }
        
    }
    else {
        [self commentUploadFailed:responseDict];
    }
}

- (void)commentUploadFailed:(NSDictionary*)responseDict
{
    
    //dismiss loading view
    [_loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    //show fail alert
    UIAlertView *failedAlertView = [[UIAlertView alloc] initWithTitle:@"Submission Failed" message:@"Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failedAlertView show];
    [failedAlertView release];
    
}

@end
