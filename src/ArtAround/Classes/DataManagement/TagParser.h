//
//  TagParser.h
//  ArtAround
//
//  Created by Samosys on 22/08/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import "ItemParser.h"
#import "Tag.h"
#import "ItemParser.h"
@interface TagParser : ItemParser
+ (NSSet *)setForTitles:(NSArray *)tagTitles inContext:(NSManagedObjectContext *)context;
+ (Tag *)tagForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context;

+ (NSArray *)arrayFortagRequest:(ASIHTTPRequest *)tagRequest;

@end
