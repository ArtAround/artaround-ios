//
//  PhotoParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "PhotoParser.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "FlickrAPIManager.h"

@implementation PhotoParser

- (void)parseRequest:(ASIHTTPRequest *)request
{
	//deserialize the json response
	NSError *jsonError = nil;
	NSDictionary *responseDict = [[request responseData] objectFromJSONDataWithParseOptions:JKParseOptionNone error:&jsonError];
	
	//check for an error
	if (jsonError || !responseDict) {
		DebugLog(@"PhotoParser error: %@", jsonError);
		return;
	}
	
	//lock the context
	[self.managedObjectContext lock];
	
	//grab the sizes and check that they exist
	NSDictionary *sizesDict = [responseDict objectForKey:@"sizes"];
	if (!sizesDict) {
		DebugLog(@"PhotoParser error: %@", [request responseString]);
		return;
	}
	
	DebugLog(@"%@", [request responseString]);
	
	//parse the photo info returned and add to/update the local data
	id flickrID = [[request userInfo] objectForKey:[FlickrAPIManager flickrIDKey]];
	[PhotoParser photoForFlickrID:flickrID sizesDict:sizesDict inContext:self.managedObjectContext];
	
	//pass the userInfo along to the managedObjectContext
	[[self managedObjectContext] setUserInfo:[request userInfo]];
	
	//save the photo
	@try {
		NSError *error = nil;
		if (![[self managedObjectContext] save:&error]) {
			DebugLog(@"Error saving to the database: %@, %@", error, [error userInfo]);
		}
	}
	@catch (NSException * e) {
		DebugLog(@"Could not save photo");
	}
	
	//unlock the context
	[self.managedObjectContext unlock];
}

+ (NSSet *)setForPhotoDicts:(NSArray *)photoDicts inContext:(NSManagedObjectContext *)context
{
    
	NSMutableSet *photos = [NSMutableSet set];
	for (NSDictionary *photoDict in photoDicts) {
		
		//get the photo for the given flickrID
		//add the photo to the set
		Photo *photo = [PhotoParser photoForPhotoDict:photoDict inContext:context];
		[photos addObject:photo];
		
	}
	return photos;
}

+ (NSSet *)setForFlickrIDs:(NSArray *)flickrIDs inContext:(NSManagedObjectContext *)context
{
    
	NSMutableSet *photos = [NSMutableSet set];
	for (NSNumber *flickrID in flickrIDs) {
		
		//get the photo for the given flickrID
		//add the photo to the set
		Photo *photo = [PhotoParser photoForFlickrID:flickrID inContext:context];
		[photos addObject:photo];
		
	}
	return photos;
}

+ (Photo *)photoForFlickrID:(NSNumber *)flickrID inContext:(NSManagedObjectContext *)context
{	
	//every once in a while a string is passed
	if ([flickrID isKindOfClass:[NSString class]]) {
		flickrID = [NSNumber numberWithLongLong:[flickrID longLongValue]];
	}
	
	//create a new photo if one doesn't exist yet
	Photo *photo = [ItemParser existingEntity:@"Photo" inContext:context uniqueKey:@"flickrID" uniqueValue:flickrID];
	if (!photo) {
		photo = (Photo *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.flickrID = [AAAPIManager clean:flickrID];
	}
	return photo;
}

+ (Photo *)photoForPhotoDict:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context
{	
	//every once in a while a string is passed
	if (![photoDict isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	
    NSNumber *primary = [NSNumber numberWithBool:NO];
    NSString *originalURL = @"";
    NSString *mediumURL = @"";
    NSString *thumbnailURL = @"";
    NSString *flickrName = @"";
    NSString *photoAttribution = @"";
    NSString *photoAttributionURL = @"";
    NSDate *addedDate = [NSDate date];
    
    if (![[photoDict objectForKey:@"primary"] isKindOfClass:[NSNull class]]) {
        primary = [AAAPIManager clean:[photoDict objectForKey:@"primary"]];
    }
    
    if (![[photoDict objectForKey:@"image_big_url"] isKindOfClass:[NSNull class]]) {    
        originalURL = [AAAPIManager clean:[photoDict objectForKey:@"image_big_url"]];
    }

    if (![[photoDict objectForKey:@"image_small_url"] isKindOfClass:[NSNull class]]) {    
        mediumURL = [AAAPIManager clean:[photoDict objectForKey:@"image_small_url"]];
    }

    if (![[photoDict objectForKey:@"image_thumbnail_url"] isKindOfClass:[NSNull class]]) {    
        thumbnailURL = [AAAPIManager clean:[photoDict objectForKey:@"image_thumbnail_url"]];
    }    
    
    if (![[photoDict objectForKey:@"flickr_username"] isKindOfClass:[NSNull class]]) {    
        flickrName = [AAAPIManager clean:[photoDict objectForKey:@"flickr_username"]];
    }
    
    if (![[photoDict objectForKey:@"attribution_text"] isKindOfClass:[NSNull class]]) {
        photoAttribution = [AAAPIManager clean:[photoDict objectForKey:@"attribution_text"]];
    }
    
    if (![[photoDict objectForKey:@"attribution_url"] isKindOfClass:[NSNull class]]) {
        photoAttributionURL = [AAAPIManager clean:[photoDict objectForKey:@"attribution_url"]];
    }
    
    if (!originalURL || originalURL.length <= 0)
        return nil;
    
	//create a new photo if one doesn't exist yet
	Photo *photo = [ItemParser existingEntity:@"Photo" inContext:context uniqueKey:@"originalURL" uniqueValue:originalURL];
	if (!photo) {
		photo = (Photo *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.originalURL = [AAAPIManager clean:originalURL];
        
        if (mediumURL || mediumURL.length > 0)
            photo.mediumURL = mediumURL;
        
        if (thumbnailURL || thumbnailURL.length > 0)
            photo.thumbnailURL = thumbnailURL;
        
        if (flickrName || flickrName.length > 0)
            photo.flickrName = flickrName;
        
        if (photoAttribution || photoAttribution.length > 0)
            photo.photoAttribution = photoAttribution;
        
        if (photoAttributionURL || photoAttributionURL.length > 0)
            photo.photoAttributionURL = photoAttributionURL;
        
        photo.dateAdded = addedDate;
            
	}
    
    
	return photo;
}

+ (Photo *)photoForFlickrID:(NSNumber *)flickrID sizesDict:(NSDictionary *)sizesDict inContext:(NSManagedObjectContext *)context
{
	//get the existing photo
	Photo *photo = [PhotoParser photoForFlickrID:flickrID inContext:context];
	
	//set the photo attribtues
	NSArray *sizes = [sizesDict objectForKey:@"size"];
	for (NSDictionary *sizeDict in sizes) {
		
		//grab all the values
		NSString *label = [[sizeDict objectForKey:@"label"] lowercaseString];
		NSNumber *height = [sizeDict objectForKey:@"height"];
		NSNumber *width = [sizeDict objectForKey:@"width"];
		NSString *source = [sizeDict objectForKey:@"source"];
		NSString *url = [sizeDict objectForKey:@"url"];
		
		//sometimes the height/width is returned as a string
		if ([height isKindOfClass:[NSString class]]) {
			height = [NSNumber numberWithInt:[(NSString *)height intValue]];
		}
		if ([width isKindOfClass:[NSString class]]) {
			width = [NSNumber numberWithInt:[(NSString *)width intValue]];
		}

		//assign to the proper place based on the label
		//this isn't very pretty, but it'll do
		if ([label isEqualToString:@"square"]) {
			photo.squareHeight = height;
			photo.squareWidth = width;
			photo.squareSource = source;
			photo.squareURL = url;
		} else if ([label isEqualToString:@"thumbnail"]) {
			photo.thumbnailHeight = height;
			photo.thumbnailWidth = width;
			photo.thumbnailSource = source;
			photo.thumbnailURL = url;
		} else if ([label isEqualToString:@"small"]) {
			photo.smallHeight = height;
			photo.smallWidth = width;
			photo.smallSource = source;
			photo.smallURL = url;
		} else if ([label isEqualToString:@"medium"]) {
			photo.mediumHeight = height;
			photo.mediumWidth = width;
			photo.mediumSource = source;
			photo.mediumURL = url;
		} else if ([label isEqualToString:@"original"]) {
			photo.originalHeight = height;
			photo.originalWidth = width;
			photo.originalSource = source;
			photo.originalURL = url;
		}
		
	}
	
	return photo;
}

@end
