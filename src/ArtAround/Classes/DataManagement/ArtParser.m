//
//  ArtParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "ArtParser.h"
#import "AAAPIManager.h"
#import "JSONKit.h"
#import "Art.h"
#import "Photo.h"
#import "Category.h"
#import "Neighborhood.h"
#import "NeighborhoodParser.h"
#import "CategoryParser.h"
#import "PhotoParser.h"

@implementation ArtParser

#pragma mark - Instance Methods

- (void)parseRequest:(ASIHTTPRequest *)request
{	
	//deserialize the json response
	NSError *jsonError = nil;
	NSDictionary *responseDict = [[request responseData] objectFromJSONDataWithParseOptions:JKParseOptionNone error:&jsonError];
	
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
		[ArtParser artForDict:artDict inContext:self.managedObjectContext];
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

#pragma mark - Class Methods

+ (Art *)artForDict:(NSDictionary *)artDict inContext:(NSManagedObjectContext *)context
{
	//create a new art if one doesn't exist yet
	NSString *slug = [artDict objectForKey:@"slug"];
	Art *art = [ItemParser existingEntity:@"Art" inContext:context uniqueKey:@"slug" uniqueValue:slug];
	if (!art) {
		art = (Art *)[NSEntityDescription insertNewObjectForEntityForName:@"Art" inManagedObjectContext:context];
	}
	
	//set the art attribtues
	art.slug = slug;
	art.locationDescription = [AAAPIManager clean:[artDict objectForKey:@"location_description"]];
	art.artist = [AAAPIManager clean:[artDict objectForKey:@"artist"]];
	art.title = [AAAPIManager clean:[artDict objectForKey:@"title"]];
	art.year = [AAAPIManager clean:[NSNumber numberWithInt:[[artDict objectForKey:@"year"] intValue]]];
	art.ward = [AAAPIManager clean:[NSNumber numberWithInt:[[artDict objectForKey:@"ward"] intValue]]];
	art.createdAt = [[ItemParser dateFormatter] dateFromString:[artDict objectForKey:@"created_at"]];
	art.category = [CategoryParser categoryForTitle:[artDict objectForKey:@"category"] inContext:context];
	art.neighborhood = [NeighborhoodParser neighborhoodForTitle:[artDict objectForKey:@"neighborhood"] inContext:context];
	art.photos = [PhotoParser setForFlickrIDs:[artDict objectForKey:@"flickr_ids"] inContext:context];
	
	//make sure we don't have empty artist
	if (art.artist) {
		art.artist = [art.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else {
		art.artist = @"";
	}
	if ([art.artist isEqualToString:@""] || [art.artist isEqualToString:@"?"]) {
		art.artist = @"Unknown";
	}
	
	//location
	NSArray *location = [artDict objectForKey:@"location"];
	if ([location count] >= 2) {
		art.latitude = [AAAPIManager clean:[location objectAtIndex:0]];
		art.longitude = [AAAPIManager clean:[location objectAtIndex:1]];
	}
	
	//todo: comments
	
	return art;
}

@end
