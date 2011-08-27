//
//  NeighborhoodParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Neighborhood.h"
#import "ItemParser.h"

@interface NeighborhoodParser : ItemParser

+ (NSSet *)setForTitles:(NSArray *)neighborhoodTitles inContext:(NSManagedObjectContext *)context;
+ (Neighborhood *)neighborhoodForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context;
+ (NSArray *)arrayForNeighborhoodRequest:(ASIHTTPRequest *)neighborhoodRequest;

@end
