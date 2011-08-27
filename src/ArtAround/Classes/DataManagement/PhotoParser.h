//
//  PhotoParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import "ItemParser.h"

@interface PhotoParser : ItemParser

+ (Photo *)photoForFlickrID:(NSNumber *)flickrID inContext:(NSManagedObjectContext *)context;
+ (NSSet *)setForFlickrIDs:(NSArray *)flickrIDs inContext:(NSManagedObjectContext *)context;

@end
