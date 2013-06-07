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
#import "CommentParser.h"
#import "EventParser.h"

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
    
    //parse the single art returned and add to/update the local data
    NSDictionary *singleArtDict = [responseDict objectForKey:@"art"];
    if (singleArtDict) {
        [ArtParser artForDict:singleArtDict inContext:self.managedObjectContext];
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
    art.artDescription = [AAAPIManager clean:[artDict objectForKey:@"description"]];
	art.artist = [AAAPIManager clean:[artDict objectForKey:@"artist"]];
	art.title = [AAAPIManager clean:[artDict objectForKey:@"title"]];
    if ([artDict objectForKey:@"year"] && ![[artDict objectForKey:@"year"] isKindOfClass:[NSNull class]])
        art.year = [AAAPIManager clean:[NSNumber numberWithInt:[[artDict objectForKey:@"year"] intValue]]];

	if ([artDict objectForKey:@"ward"] && ![[artDict objectForKey:@"ward"] isKindOfClass:[NSNull class]])
        art.ward = [AAAPIManager clean:[NSNumber numberWithInt:[[artDict objectForKey:@"ward"] intValue]]];
    
    if ([artDict objectForKey:@"created_at"] && ![[artDict objectForKey:@"created_at"] isKindOfClass:[NSNull class]])
        art.createdAt = [[ItemParser dateFormatter] dateFromString:[artDict objectForKey:@"created_at"]];
    
    //categories    
    if ([artDict objectForKey:@"category"] && [[artDict objectForKey:@"category"] isKindOfClass:[NSArray class]])
        art.categories = [CategoryParser setForTitles:[artDict objectForKey:@"category"] inContext:context];
    
    //neighborhood
	art.neighborhood = [NeighborhoodParser neighborhoodForTitle:[artDict objectForKey:@"neighborhood"] inContext:context];
    
    //photos
    if ([artDict objectForKey:@"photos"] && ![[artDict objectForKey:@"photos"] isKindOfClass:[NSNull class]]) {
        //art.photos = [PhotoParser setForFlickrIDs:[artDict objectForKey:@"flickr_ids"] inContext:context];
        art.photos = [PhotoParser setForPhotoDicts:[artDict objectForKey:@"photos"] inContext:context];
    }
	
    //commissioned
    if ([artDict objectForKey:@"commissioned"] && ![[artDict objectForKey:@"commissioned"] isKindOfClass:[NSNull class]])
        art.commissioned = [AAAPIManager clean:[NSNumber numberWithBool:[[artDict objectForKey:@"commissioned"] boolValue]]];
    else {
        art.commissioned = [NSNumber numberWithBool:NO];
    }

    
    //get the event if it exists
    if ([artDict objectForKey:@"event"] && [[artDict objectForKey:@"event"] isKindOfClass:[NSDictionary class]])
        art.event = [EventParser eventForDictionary:[artDict objectForKey:@"event"] inContext:context];
    
    //get the rank if it exists
    if ([artDict objectForKey:@"ranking"] && ![[artDict objectForKey:@"ranking"] isKindOfClass:[NSNull class]])   
        art.rank = [AAAPIManager clean:[NSNumber numberWithInt:[[artDict objectForKey:@"ranking"] intValue]]];
    else 
        art.rank = [AAAPIManager clean:[NSNumber numberWithInt:-1]];
    
    //get comments if they exist
    if ([artDict objectForKey:@"comments"] && [[artDict objectForKey:@"comments"] isKindOfClass:[NSArray class]])
        art.comments = [CommentParser setForArray:[artDict objectForKey:@"comments"] inContext:context];
    
    
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
        //check to see if this object is a string or number
        if ([[location objectAtIndex:0] isKindOfClass:[NSString class]])
            art.latitude = [NSDecimalNumber decimalNumberWithString:[AAAPIManager clean:[location objectAtIndex:0]]];
        else
            art.latitude = [AAAPIManager clean:[location objectAtIndex:0]];
        
        //check to see if this object is a string or number
        if ([[location objectAtIndex:0] isKindOfClass:[NSString class]])
            art.longitude = [NSDecimalNumber decimalNumberWithString:[AAAPIManager clean:[location objectAtIndex:1]]];
        else
            art.longitude = [AAAPIManager clean:[location objectAtIndex:1]];
        
	}

	
	return art;
}

+ (BOOL)setFavorite:(BOOL)fav forSlug:(NSString*)slug
{
    Art *art = [ItemParser existingEntity:@"Art" inContext:[AAAPIManager managedObjectContext] uniqueKey:@"slug" uniqueValue:slug];
	if (!art) {
        return NO;
    }

    art.favorite = [NSNumber numberWithBool:fav];;
    return YES;
    
}

@end
