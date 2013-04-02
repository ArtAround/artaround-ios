//
//  EventParser.h
//  ArtAround
//
//  Created by Brian Singer on 3/11/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "ItemParser.h"
#import "Event.h"

@interface EventParser : ItemParser

+ (NSSet *)setForDictionaries:(NSArray *)eventDictionaries inContext:(NSManagedObjectContext *)context;
+ (Event *)eventForDictionary:(NSDictionary *)eventData inContext:(NSManagedObjectContext *)context;


@end
