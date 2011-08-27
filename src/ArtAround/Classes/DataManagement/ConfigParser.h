//
//  ConfigParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import <Foundation/Foundation.h>
#import "ItemParser.h"

@interface ConfigParser : ItemParser

- (void)parseCategoryRequest:(ASIHTTPRequest *)categoryRequest neighborhoodRequest:(ASIHTTPRequest *)neighborhoodRequest userInfo:(NSDictionary *)userInfo;

@end
