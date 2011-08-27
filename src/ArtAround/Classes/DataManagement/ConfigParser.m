//
//  ConfigParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import "ConfigParser.h"
#import "AAAPIManager.h"
#import "CJSONDeserializer.h"
#import	"Neighborhood.h"
#import	"Category.h"

@implementation ConfigParser

- (void)parseCategoryRequest:(ASIHTTPRequest *)categoryRequest neighborhoodRequest:(ASIHTTPRequest *)neighborhoodRequest userInfo:(NSDictionary *)userInfo
{	
	//deserialize the json response
	NSError *neighborhoodError = nil;
	NSArray *neighborhoods = [[CJSONDeserializer deserializer] deserialize:[neighborhoodRequest responseData] error:&neighborhoodError];
	
	//check for an error
	if (neighborhoodError || !neighborhoods) {
		DebugLog(@"neighborhoodError: %@", neighborhoodError);
		return;
	}
	
	//lock the context
	[self.managedObjectContext lock];
	
	//todo: check and see if any neighborhoods were removed from the list
	//parse the neighborhoods returned and add to/update the local data
	for (NSString *title in neighborhoods) {
		
		//create a new category if one doesn't exist yet
		Neighborhood *neighborhood = [AAAPIManager existingEntity:@"Neighborhood" inContext:self.managedObjectContext uniqueKey:@"title" uniqueValue:title];
		if (!neighborhood) {
			neighborhood = (Neighborhood *)[NSEntityDescription insertNewObjectForEntityForName:@"Neighborhood" inManagedObjectContext:self.managedObjectContext];
			neighborhood.title = title;
		}
		
	}
	
	//deserialize the json response
	NSError *error = nil;
	NSArray *categories = [[CJSONDeserializer deserializer] deserialize:[categoryRequest responseData] error:&error];
	
	if (error || !categories) {
		DebugLog(@"downloadCategories error: %@", error);
	}
	
	//todo: check and see if any categories were removed from the list
	//parse the categories returned and add to/update the local data
	for (NSString *title in categories) {
		
		//create a new category if one doesn't exist yet
		Category *category = [AAAPIManager existingEntity:@"Category" inContext:self.managedObjectContext uniqueKey:@"title" uniqueValue:title];
		if (!category) {
			category = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
			category.title = title;
		}
		
	}
	
	//pass the userInfo along to the managedObjectContext
	[[self managedObjectContext] setUserInfo:userInfo];

	//save the art
	@try {
		NSError *error = nil;
		if (![[self managedObjectContext] save:&error]) {
			DebugLog(@"Error saving to the database: %@, %@", error, [error userInfo]);
		}
	}
	@catch (NSException * e) {
		DebugLog(@"Could not save art");
	}
	
	//unlock the context
	[self.managedObjectContext unlock];
}

- (void)dealloc {
	[_dateFormatter release];
    [super dealloc];
}

@end
