//
//  ArtistParser.h
//  ArtAround
//
//  Created by samosys on 20/02/16.
//  Copyright © 2016 ArtAround. All rights reserved.
//

#import "ItemParser.h"
#import "Artist.h"

@interface ArtistParser : ItemParser
+ (NSSet *)setForTitles:(NSArray *)artistTitles inContext:(NSManagedObjectContext *)context;
+ (Artist *)artistForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context;

+ (NSArray *)arrayFortagRequest:(ASIHTTPRequest *)tagRequest;

@end
