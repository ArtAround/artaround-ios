//
//  ArtParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemParser.h"
#import "Art.h"

@interface ArtParser : ItemParser

- (void)parseRequest:(ASIHTTPRequest *)request;
+ (Art *)artForDict:(NSDictionary *)artDict inContext:(NSManagedObjectContext *)context;

@end
