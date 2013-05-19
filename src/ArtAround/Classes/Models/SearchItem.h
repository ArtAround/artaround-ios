//
//  SearchItem.h
//  ArtAround
//
//  Created by Brian Singer on 5/19/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchItem : NSObject

@property (nonatomic, copy) NSString *title, *subtitle;

+ (id) searchItemWithTitle:(NSString*)title subtitle:(NSString*)subtitle;

@end
