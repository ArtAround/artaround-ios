//
//  PhotoParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import "ItemParser.h"

@interface PhotoParser : ItemParser

- (void)parseRequest:(ASIHTTPRequest *)request;
+ (Photo *)photoForFlickrID:(NSNumber *)flickrID inContext:(NSManagedObjectContext *)context;
+ (Photo *)photoForFlickrID:(NSNumber *)flickrID sizesDict:(NSDictionary *)sizesDict inContext:(NSManagedObjectContext *)context;
+ (NSSet *)setForFlickrIDs:(NSArray *)flickrIDs inContext:(NSManagedObjectContext *)context;

@end
