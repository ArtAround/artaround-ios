//
//  ConfigParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//
//  This class parses, saves, and updates cached, fairly static items such as categories and neighborhoods
//  These are all updated at the same time, hence this wrapper class

#import <Foundation/Foundation.h>
#import "ItemParser.h"

@interface ConfigParser : ItemParser

- (void)parseCategoryRequest:(ASIHTTPRequest *)categoryRequest neighborhoodRequest:(ASIHTTPRequest *)neighborhoodRequest userInfo:(NSDictionary *)userInfo;

@end
