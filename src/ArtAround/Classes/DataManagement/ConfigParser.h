//
//  ConfigParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//
//  This class parses, saves, and updates cached, fairly static items such as categories and neighborhoods
//  These are all updated at the same time, hence this wrapper class

#import <Foundation/Foundation.h>
#import "ItemParser.h"

@interface ConfigParser : ItemParser

- (void)parseCategoryRequest:(id)categoryRequest neighborhoodRequest:(id)neighborhoodRequest userInfo:(NSDictionary *)userInfo;

@end
