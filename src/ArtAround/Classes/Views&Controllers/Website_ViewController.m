//
//  Website_ViewController.m
//  ArtAround
//
//  Created by Innobitz on 01/06/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import "Website_ViewController.h"

@interface Website_ViewController ()
{
    UIActivityIndicatorView *indicator;
}

@end

@implementation Website_ViewController
@synthesize url;
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backButtonImage.size.width + 10.0f, backButtonImage.size.height)];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setContentMode:UIViewContentModeCenter];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];

    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 100, 100);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"backArrow.png"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [Webview loadRequest:request];
    [indicator startAnimating];
   // [super viewWillAppear:animated];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicator stopAnimating];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [Webview release];
    [super dealloc];
}
@end
