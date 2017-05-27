//
//  PhotoImageButton.m
//  ArtAround
//
//  Created by Jerónimo Valli on 5/12/17.
//  Copyright © 2017 ArtAround. All rights reserved.
//

#import "PhotoImageButton.h"

@implementation PhotoImageButton

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    UIImage *imageToDisplay = [UIImage imageWithCGImage:[image CGImage] scale:[image scale] orientation: UIImageOrientationUp];
    [super setImage:imageToDisplay forState:state];
}

@end
