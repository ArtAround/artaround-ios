//
//  NeighborhoodParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "NeighborhoodParser.h"
//#import "JSONKit.h"

@implementation NeighborhoodParser

+ (NSSet *)setForTitles:(NSArray *)neighborhoodTitles inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *neighborhoods = [NSMutableSet set];
	for (NSString *title in neighborhoodTitles) {
		
		//get the category for the given title
		//add neighborbood to the set
		Neighborhood *neighborhood = [NeighborhoodParser neighborhoodForTitle:title inContext:context];
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
		neighborhood.title = [AAAPIManager clean:title];
	}
	return neighborhood;
}

+ (NSArray *)arrayForNeighborhoodRequest:(id)neighborhoodRequest
{
	//deserialize the json response
	NSError *error = nil;
	NSArray *neighborhoods = nil;//[[neighborhoodRequest responseData] objectFromJSONDataWithParseOptions:JKParseOptionNone error:&error];
	
	//check for an error
	if (error || !neighborhoods) {
		DebugLog(@"arrayForNeighborhoodRequest error: %@", error);
	}
	
	return neighborhoods;
}

@end
