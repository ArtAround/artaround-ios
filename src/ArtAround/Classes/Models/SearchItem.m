//
//  SearchItem.m
//  ArtAround
//
//  Created by Brian Singer on 5/19/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "SearchItem.h"

@implementation SearchItem

@synthesize title, subtitle;

+ (id) searchItemWithTitle:(NSString*)title subtitle:(NSString*)subtitle
{
    SearchItem *item = [[self alloc] init];
    item.title = title;
    item.subtitle = subtitle;
    
    return item;
}

- (NSString*) description {
    return [NSString stringWithString:self.title];
}

@end
