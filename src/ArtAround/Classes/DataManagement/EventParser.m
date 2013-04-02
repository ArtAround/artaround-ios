//
//  EventParser.m
//  ArtAround
//
//  Created by Brian Singer on 3/11/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "EventParser.h"

@implementation EventParser

+ (NSSet *)setForDictionaries:(NSArray *)eventDictionaries inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *events = [NSMutableSet set];
	for (NSDictionary *dict in eventDictionaries) {
		
		//get the event for the given data
		//add event to the set
		Event *event = [EventParser eventForDictionary:dict inContext:context];
		[events addObject:event];
		
	}
    
	return events;
}



+ (Event *)eventForDictionary:(NSDictionary *)eventData inContext:(NSManagedObjectContext *)context
{
	//get or create a event with the given data
	Event *event = [ItemParser existingEntity:@"Event" inContext:context uniqueKey:@"slug" uniqueValue:[eventData objectForKey:kEventSlugKey]];
	if (!event) {
		event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
        event.slug = [AAAPIManager clean:[eventData objectForKey:kEventSlugKey]];		
        event.iconURL = [AAAPIManager clean:[eventData objectForKey:kEventIconURLKey]];		
        event.iconURLSmall = [AAAPIManager clean:[eventData objectForKey:kEventIconURLSmallKey]];		
        if ([eventData objectForKey:kEventNameKey] && [[eventData objectForKey:kEventNameKey] isKindOfClass:[NSString class]])
            event.name = [AAAPIManager clean:[eventData objectForKey:kEventNameKey]];

        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        //check for start date
        if ([eventData objectForKey:kEventStartsKey] && [[eventData objectForKey:kEventStartsKey] isKindOfClass:[NSString class]]) {
        
            event.starts = [dateFormatter dateFromString:[[eventData objectForKey:kEventStartsKey] substringToIndex:10]];
        }
        
        //check for end date        
        if ([eventData objectForKey:kEventEndsKey] && [[eventData objectForKey:kEventEndsKey] isKindOfClass:[NSString class]]) {
            
            event.ends = [dateFormatter dateFromString:[[eventData objectForKey:kEventEndsKey] substringToIndex:10]];       
        }
        
        //check for desc
        if ([eventData objectForKey:kEventDescriptionKey] && [[eventData objectForKey:kEventDescriptionKey] isKindOfClass:[NSString class]])
            event.eventDescription = [AAAPIManager clean:[eventData objectForKey:kEventDescriptionKey]];
        
        
        if ([eventData objectForKey:kEventWebsiteKey] && [[eventData objectForKey:kEventWebsiteKey] isKindOfClass:[NSString class]])
            event.website = [AAAPIManager clean:[eventData objectForKey:kEventWebsiteKey]];        
	}
    
	return event;
}




@end
