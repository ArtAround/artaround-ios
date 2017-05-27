//
//  Website_ViewController.h
//  ArtAround
//
//  Created by Innobitz on 01/06/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Website_ViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView *Webview;
    
}
@property (nonatomic , strong)NSString *url;
@end
