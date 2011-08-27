//
//  NeighborhoodParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "NeighborhoodParser.h"
#import "CJSONDeserializer.h"

@implementation NeighborhoodParser

+ (NSSet *)setForTitles:(NSArray *)neighborhoodTitles inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *neighborhoods = [NSMutableSet set];
	for (NSString *title in neighborhoodTitles) {
		
		//create a new neighborhood if one doesn't exist yet
		Neighborhood *neighborhood = [ItemParser existingEntity:@"Neighborhood" inContext:context uniqueKey:@"title" uniqueValue:title];
		if (!neighborhood) {
			neighborhood = (Neighborhood *)[NSEntityDescription insertNewObjectForEntityForName:@"Neighborhood" inManagedObjectContext:context];
			neighborhood.title = title;
		}
		
		//add neighborbood to the set
		[neighborhoods addObject:neighborhood];
		
	}
	return neighborhoods;
}

+ (Neighborhood *)neighborhoodForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context
{
	//get or create a neighborhood with the given title
	Neighborhood *neighborhood = [ItemParser existingEntity:@"Neighborhood" inContext:context uniqueKey:@"title" uniqueValue:title];
	if (!neighborhood) {
		neighborhood = (Neighborhood *)[NSEntityDescription insertNewObjectForEntityForName:@"Neighborhood" inManagedObjectContext:context];
		neighborhood.title = title;
	}
	return neighborhood;
}

+ (NSArray *)arrayForNeighborhoodRequest:(ASIHTTPRequest *)neighborhoodRequest
{
	//deserialize the json response
	NSError *error = nil;
	NSArray *neighborhoods = [[CJSONDeserializer deserializer] deserialize:[neighborhoodRequest responseData] error:&error];
	
	//check for an error
	if (error || !neighborhoods) {
		DebugLog(@"arrayForNeighborhoodRequest error: %@", error);
	}
	
	return neighborhoods;
}

@end
