//
//  ArtParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import "ArtParser.h"
#import "AAAPIManager.h"
#import "CJSONDeserializer.h"
#import "Art.h"
#import "Photo.h"
#import "Category.h"
#import "Neighborhood.h"

@implementation ArtParser

- (void)parseRequest:(ASIHTTPRequest *)request
{	
	//deserialize the json response
	NSError *jsonError = nil;
	NSDictionary *responseDict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&jsonError];
	
	//check for an error
	if (jsonError || !responseDict) {
		DebugLog(@"artRequestCompleted error: %@", jsonError);
		return;
	}
	
	//lock the context
	[self.managedObjectContext lock];
	
	//parse the art returned and add to/update the local data
	NSArray *arts = [responseDict objectForKey:@"arts"];
	for (NSDictionary *artDict in arts) {
		
		//create a new art if one doesn't exist yet
		NSString *slug = [artDict objectForKey:@"slug"];
		Art *art = [AAAPIManager existingEntity:@"Art" inContext:self.managedObjectContext uniqueKey:@"slug" uniqueValue:slug];
		if (!art) {
			art = (Art *)[NSEntityDescription insertNewObjectForEntityForName:@"Art" inManagedObjectContext:self.managedObjectContext];
		}
		
		//set the art attribtues
		art.slug = slug;
		art.locationDescription = [artDict objectForKey:@"location_description"];
		art.artist = [artDict objectForKey:@"artist"];
		art.title = [artDict objectForKey:@"title"];
		art.ward = [NSNumber numberWithInt:[[artDict objectForKey:@"ward"]intValue]];
		art.createdAt = [_dateFormatter dateFromString:[artDict objectForKey:@"created_at"]];
		
		//location
		NSArray *location = [artDict objectForKey:@"location"];
		if ([location count] >= 2) {
			art.latitude = [location objectAtIndex:0];
			art.longitude = [location objectAtIndex:1];
		}
		
		//photos
		NSArray *flickrIDs = [artDict objectForKey:@"flickr_ids"];
		for (NSNumber *flickrID in flickrIDs) {
			
			//create a new photo if one doesn't exist yet
			Photo *photo = [AAAPIManager existingEntity:@"Photo" inContext:self.managedObjectContext uniqueKey:@"flickrID" uniqueValue:flickrID];
			if (!photo) {
				photo = (Photo *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
				photo.flickrID = flickrID;
			}
			
			//if the photo doesn't exist for the art yet, add it
			NSMutableSet *photos = [NSMutableSet setWithSet:art.photos];
			if (photo && ![photos containsObject:photo]) {
				[photos addObject:photo];
				art.photos = photos;
			}
		}
		
		//category
		//create a new category if one doesn't exist yet
		NSString *categoryTitle = [artDict objectForKey:@"category"];
		Category *category = [AAAPIManager existingEntity:@"Category" inContext:self.managedObjectContext uniqueKey:@"title" uniqueValue:categoryTitle];
		if (!category) {
			category = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
			category.title = categoryTitle;
		}
		art.category = category;
		
		//neighborhood
		//create a new neighborhood if one doesn't exist yet
		NSString *neighborhoodTitle = [artDict objectForKey:@"neighborhood"];
		Neighborhood *neighborhood = [AAAPIManager existingEntity:@"Neighborhood" inContext:self.managedObjectContext uniqueKey:@"title" uniqueValue:neighborhoodTitle];
		if (!neighborhood) {
			neighborhood = (Neighborhood *)[NSEntityDescription insertNewObjectForEntityForName:@"Neighborhood" inManagedObjectContext:self.managedObjectContext];
			neighborhood.title = neighborhoodTitle;
		}
		art.neighborhood = neighborhood;
		
		//todo: comments
		
	}
	
	//pass the userInfo along to the managedObjectContext
	[[self managedObjectContext] setUserInfo:[request userInfo]];

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
