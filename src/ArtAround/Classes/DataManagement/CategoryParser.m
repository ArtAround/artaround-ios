//
//  CategoryParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "CategoryParser.h"
#import "CJSONDeserializer.h"

@implementation CategoryParser

+ (NSSet *)setForTitles:(NSArray *)categoryTitles inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *categories = [NSMutableSet set];
	for (NSString *title in categoryTitles) {
		
		//get the category for the given title
		//add cateogry to the set
		Category *category = [CategoryParser categoryForTitle:title inContext:context];
		[categories addObject:category];
		
	}
	return categories;
}

+ (Category *)categoryForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context
{
	//get or create a category with the given title
	Category *category = [ItemParser existingEntity:@"Category" inContext:context uniqueKey:@"title" uniqueValue:title];
	if (!category) {
		category = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
		category.title = [AAAPIManager clean:title];
	}
	return category;
}

+ (NSArray *)arrayForCategoryRequest:(ASIHTTPRequest *)categoryRequest
{
	//deserialize the json response
	NSError *error = nil;
	NSArray *categories = [[CJSONDeserializer deserializer] deserialize:[categoryRequest responseData] error:&error];
	
	//check for an error
	if (error || !categories) {
		DebugLog(@"arrayForCategoryRequest error: %@", error);
	}
	
	return categories;
}

@end
