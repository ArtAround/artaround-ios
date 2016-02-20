//
//  CateTagViewController.h
//  ArtAround
//
//  Created by samosys on 18/02/16.
//  Copyright © 2016 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Art;
@interface CateTagViewController : UIViewController{
    Art* _art;
}
@property (nonatomic, retain) NSMutableArray *searchItems;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *type;
@end
