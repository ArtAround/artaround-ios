//
//  AAAPIManager.m
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "AAAPIManager.h"
#import <CoreData/CoreData.h>
#import <sqlite3.h>
#import "AFNetworking.h"
#import "ArtAroundAppDelegate.h"
#import "Art.h"
#import "Category.h"
#import "Photo.h"
#import "Comment.h"
#import "Neighborhood.h"
#import "EGOCache.h"
#import "Utilities.h"
#import "NSManagedObject+MagicalDataImport.h"
#import "MagicalImportFunctions.h"

static AAAPIManager *_sharedInstance = nil;
static const NSString *_kAPIRoot = @"http://theartaround.us/api/v1/";
static const NSString *_kFlagAPIRoot = @"http://theartaround.us/arts";
//static const NSString *_kAPIRoot = @"http://staging.theartaround.us/api/v1/";
//static const NSString *_kFlagAPIRoot = @"http://staging.theartaround.us/arts";
static const NSString *_kAPIFormat = @"json";
static const NSString *_kTargetKey = @"target";
static const NSString *_kCallbackKey = @"callback";
static const NSString *_kFailCallbackKey = @"failCallback";

//private methods
@interface AAAPIManager (private)
- (NSArray *)arrayForSQL:(char *)sql;
+ (BOOL)isCacheExpiredForURL:(NSURL *)url;
+ (BOOL)isCacheExpiredForURL:(NSURL *)url timeout:(int)timeout;
+ (NSURL *)apiURLForMethod:(NSString *)method;
+ (NSURL *)apiURLForMethod:(NSString *)method parameters:(NSDictionary *)parametersDict;
@end

@implementation AAAPIManager

//- (void)itemParserContextDidSave:(NSNotification *)notification
//{	
//	//merge core data changes on the main thread
//	[self performSelectorOnMainThread:@selector(mergeChanges:) withObject:notification waitUntilDone:YES];
//	
//	//call the selector on the target if applicable
//	NSDictionary *userInfo = [[notification object] userInfo];
//	if (userInfo) {
//		id target = [userInfo objectForKey:_kTargetKey];
// 		SEL callback = [[userInfo objectForKey:_kCallbackKey] pointerValue];
//		if (target && [target respondsToSelector:callback]) {
//			[target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
//		}
//	}
//}
//
////merges changes from other managed object context
//- (void)mergeChanges:(NSNotification *)notification
//{	
//	[[AAAPIManager managedObjectContext] lock];
//	[[AAAPIManager persistentStoreCoordinator] lock];
//	[[AAAPIManager managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
//	NSError *error = nil;
//	if (![[AAAPIManager managedObjectContext] save:&error] || error) {
//		DebugLog(@"Error saving after merge to the database: %@, %@", error, [error userInfo]);
//	}
//    
//	[[AAAPIManager persistentStoreCoordinator] unlock];
//	[[AAAPIManager managedObjectContext] unlock];
//}


#pragma mark - Arrays for Filters

//returns an array of items for the sql statement passed
//note: this only returns the first column from the results in the array and it must be a string
- (NSArray *)arrayForSQL:(char *)sql
{
	//an array to hold the results
	NSMutableArray *items = [[NSMutableArray alloc] init];
	[items addObject:@"All"];
	
	//get the path to the documents directory and append the database name
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = ([documentPaths count] > 0) ? [documentPaths objectAtIndex:0] : nil;
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:@"ArtAround.sqlite"];
	
	//open the database from the users filessytem
	sqlite3 *database;
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		//setup the SQL Statement and compile it for faster access
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sql, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				
				//add each row results
				NSString *item = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				[items addObject:item];
			}
		}
		
		//release the compiled statement
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
	
	return items;
}

- (NSArray *)categories
{
    NSArray *categories = [[NSArray alloc] initWithObjects:
                                    @"Architecture",
                                    @"Digital",
                                    @"Drawing",
                                    @"Gallery",
                                    @"Graffiti",
                                    @"Installation",
                                    @"Interactive",
                                    @"Kinetic",
                                    @"Lighting installation",
                                    @"Market",
                                    @"Memorial",
                                    @"Mixed media",
                                    @"Mosaic",
                                    @"Mural",
                                    @"Museum",
                                    @"Painting",
                                    @"Performance",
                                    @"Paste",
                                    @"Photograph",
                                    @"Print",
                                    @"Projection",
                                    @"Sculpture",
                                    @"Statue",
                                    @"Stained glass",
                                    @"Temporary",
                                    @"Textile",
                           @"Video", nil];
    return categories;
}

- (NSArray *)commissioners
{
	return [self arrayForSQL:"SELECT DISTINCT ZCOMMISSIONEDBY FROM ZART WHERE ZCOMMISSIONEDBY IS NOT NULL ORDER BY ZCOMMISSIONEDBY"];
}
- (NSArray *)neighborhoods
{
	return [self arrayForSQL:"SELECT DISTINCT ZTITLE FROM ZNEIGHBORHOOD WHERE ZTITLE IS NOT NULL ORDER BY ZTITLE"];
}

- (NSArray *)titles
{
	return [self arrayForSQL:"SELECT DISTINCT ZTITLE FROM ZART WHERE ZTITLE IS NOT NULL ORDER BY ZTITLE"];
}

- (NSArray *)artists
{
	return [self arrayForSQL:"SELECT DISTINCT ZARTIST FROM ZART WHERE ZARTIST IS NOT NULL ORDER BY ZARTIST"];
}

- (NSArray *)events
{
	return [self arrayForSQL:"SELECT ZNAME FROM ZEVENT WHERE ZSLUG IS NOT NULL ORDER BY ZNAME"];
}



#pragma mark - Flag Methods
- (void)submitFlagForSlug:(NSString*)slug withText:(NSString*)text target:(id)target callback:(SEL)callback failCallback:(SEL)failCallback
{
    
    //get the art for this slug
	NSURL *flagURL;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"source": @"iOS"}];
    if (text && text.length > 0) {
        flagURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/flag?text=%@&source=iOS", _kFlagAPIRoot, slug, [Utilities urlEncode:text], nil]];
        [params setObject:[Utilities urlEncode:text] forKey:@"text"];
    }
    else {
        flagURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/flag?source=iOS", _kFlagAPIRoot, slug, nil]];
    }
    
	//start network activity indicator
	[[Utilities instance] startActivity];
	
//    NSString *baseUrl = [[NSString alloc] initWithFormat:@"%@", _kFlagAPIRoot];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@/%@/flag", _kFlagAPIRoot, slug, nil] parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        if (target && [target respondsToSelector:callback]) {
            [target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (target && [target respondsToSelector:failCallback]) {
            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
    }];
    
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
//    [client postPath:[NSString stringWithFormat:@"%@/flag", slug, nil] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        if (target && [target respondsToSelector:callback]) {
//            [target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        if (target && [target respondsToSelector:failCallback]) {
//            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    }];
    

}

#pragma mark - Art Download Methods
//download all art objects - do not force
- (void)downloadAllArtWithTarget:(id)target callback:(SEL)callback 
{
    [self downloadAllArtWithTarget:target callback:callback forceDownload:NO];
}

//download all art objects
//if force is true then download regardless of cached data
- (void)downloadAllArtWithTarget:(id)target callback:(SEL)callback forceDownload:(BOOL)force
{
	//get the all art url
	NSDictionary *params = [NSDictionary dictionaryWithObject:@"9999" forKey:@"per_page"];
	NSURL *allArtURL = [AAAPIManager apiURLForMethod:@"arts"];
	
    //TODO: Cache checking  (erase?)
	//if art is cached, quit now
	//cache for 24 hours
	if (!force && ![AAAPIManager isCacheExpiredForURL:allArtURL timeout:60 * 60 * 24]) {
		return;
	}
    
    
	//start network activity indicator
	[[Utilities instance] startActivity];
	
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:allArtURL.absoluteString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSMutableArray *arts = [NSMutableArray array];
            if ([[responseObject objectForKey:@"arts"] isKindOfClass:[NSArray class]]) {
                for (NSMutableDictionary *art in [responseObject objectForKey:@"arts"]) {
                    NSMutableDictionary *artMutable = [art mutableCopy];
                    if ([[artMutable objectForKey:@"artist"] isKindOfClass:[NSArray class]]) {
                        NSMutableString *result = [[NSMutableString alloc] init];
                        int index = 0;
                        for (NSString *artist in [artMutable objectForKey:@"artist"]) {
                            if (![artist isEqualToString:@""]) {
                                if (index > 0) {
                                    [result appendString:@", "];
                                }
                                [result appendString:artist];
                                index++;
                            }
                        }
                        artMutable[@"artist"] = result;
                    }
                    artMutable[@"title"] = [Utilities urlDecode:artMutable[@"title"]];
                    [arts addObject:artMutable];
                }
            }
            [Art MR_importFromArray:arts inContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                NSArray *arts = [responseObject objectForKey:@"arts"];
                
                NSArray *categories = [Category MR_findAll];
                for (Category *thisCat in categories) {
                    
                    NSString *catTitle = thisCat.title;
                    
                    NSArray *filteredArts = [arts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                        return ([[evaluatedObject objectForKey:@"category"] isKindOfClass:[NSArray class]] && [[evaluatedObject objectForKey:@"category"] containsObject:catTitle]);
                    }]];
                    
                    for (NSDictionary *thisArtJson in filteredArts) {
                        
                        Art *artRecord = [Art MR_findFirstByAttribute:@"artID" withValue:[thisArtJson objectForKey:@"slug"] inContext:localContext];
                        [artRecord addCategoriesObject:thisCat];
                        
                    }
                    
                }
                
            } completion:^(BOOL success, NSError *error) {
                
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [(id)target performSelector:callback withObject:nil];
                #pragma clang diagnostic pop
                
                [[Utilities instance] stopActivity];
                
            }];
            
            
        }];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DebugLog(@"Download all art failed. Error: %@.", error);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [(id)target performSelector:callback withObject:nil];
        #pragma clang diagnostic pop
        
    }];
    
//    AFJSONRequestOperation *request = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:allArtURL] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        
//        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//            [Art MR_importFromArray:[JSON objectForKey:@"arts"] inContext:localContext];
//        } completion:^(BOOL success, NSError *error) {
//            
//            
//            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//                
//                NSArray *arts = [JSON objectForKey:@"arts"];
//                
//                NSArray *categories = [Category MR_findAll];
//                for (Category *thisCat in categories) {
//                    
//                    NSString *catTitle = thisCat.title;
//                    
//                    NSArray *filteredArts = [arts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//                        return ([[evaluatedObject objectForKey:@"category"] isKindOfClass:[NSArray class]] && [[evaluatedObject objectForKey:@"category"] containsObject:catTitle]);
//                    }]];
//                    
//                    for (NSDictionary *thisArtJson in filteredArts) {
//                        
//                        Art *artRecord = [Art MR_findFirstByAttribute:@"artID" withValue:[thisArtJson objectForKey:@"slug"] inContext:localContext];
//                        [artRecord addCategoriesObject:thisCat];
//                        
//                    }
//                    
//                }
//            
//            } completion:^(BOOL success, NSError *error) {
//                
//                #pragma clang diagnostic push
//                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                    [(id)target performSelector:callback withObject:nil];
//                #pragma clang diagnostic pop
//                
//                [[Utilities instance] stopActivity];
//                
//            }];
//            
//
//        }];
//        
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        
//        DebugLog(@"Download all art failed. Error: %@.  JSON: %@", error, JSON);
//        
//        #pragma clang diagnostic push
//        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                [(id)target performSelector:callback withObject:nil];
//        #pragma clang diagnostic pop
//        
//    }];
//    [request start];
    

}

- (void)downloadArtForSlug:(NSString*)slug target:(id)target callback:(SEL)callback 
{
    //call full download method
    [self downloadArtForSlug:slug target:target callback:callback forceDownload:NO];
}

//download a single art object
//if force is true then download regardless of cached data
- (void)downloadArtForSlug:(NSString*)slug target:(id)target callback:(SEL)callback forceDownload:(BOOL)force
{
    //get the art for this slug
	NSURL *artURL = [AAAPIManager apiURLForMethod:[NSString stringWithFormat:@"arts/%@", slug, nil] parameters:nil];

    //if art is cached, quit now
	//cache for 24 hours
	if (![AAAPIManager isCacheExpiredForURL:artURL timeout:60 * 60 * 24] && !force) {
		return;
	}	
    
	//start network activity indicator
	[[Utilities instance] startActivity];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:artURL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSMutableDictionary *artMutable = [[responseObject objectForKey:@"art"] mutableCopy];
            if ([[artMutable objectForKey:@"artist"] isKindOfClass:[NSArray class]]) {
                NSMutableString *result = [[NSMutableString alloc] init];
                int index = 0;
                for (NSString *artist in [artMutable objectForKey:@"artist"]) {
                    if (![artist isEqualToString:@""]) {
                        if (index > 0) {
                            [result appendString:@"\n"];
                        }
                        [result appendString:artist];
                        index++;
                    }
                }
                artMutable[@"artist"] = result;
            }
            artMutable[@"title"] = [Utilities urlDecode:artMutable[@"title"]];
            [Art MR_importFromObject:artMutable inContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                NSDictionary *art = [responseObject objectForKey:@"art"];
                Art *artRecord = [Art MR_findFirstByAttribute:@"artID" withValue:[art objectForKey:@"slug"] inContext:localContext];
                
                //add categories
                if ([[art objectForKey:@"category"] isKindOfClass:[NSArray class]]) {
                    
                    for (NSString *thisCatTitle in [art objectForKey:@"category"]) {
                        
                        Category *catObject = [Category MR_findFirstByAttribute:@"categoryID" withValue:thisCatTitle];
                        if (catObject) {
                            [artRecord addCategoriesObject:catObject];
                        }
                        
                    }
                    
                }
                
                //add photos
                if ([[art objectForKey:@"photos"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *photoObjects = [Photo MR_importFromArray:[art objectForKey:@"photos"] inContext:localContext];
                    NSSet *photosSet = [[NSSet alloc] initWithArray:photoObjects];
                    [artRecord addPhotos:photosSet];

                    
                }
                
                //add comments
                if ([[art objectForKey:@"comments"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *commentObjects = [Comment MR_importFromArray:[art objectForKey:@"comments"] inContext:localContext];
                    NSSet *commentSet = [[NSSet alloc] initWithArray:commentObjects];
                    [artRecord addComments:commentSet];
                    
                    
                }
                
            } completion:^(BOOL success, NSError *error) {
                
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [(id)target performSelector:callback withObject:nil];
                #pragma clang diagnostic pop
                
                [[Utilities instance] stopActivity];
                
            }];
            
            
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        DebugLog(@"Download art failed. Error: %@.", error);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [(id)target performSelector:callback withObject:nil];
        #pragma clang diagnostic pop
        
    }];
    
//    AFJSONRequestOperation *request = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:artURL] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        
//        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//            [Art MR_importFromObject:[JSON objectForKey:@"art"] inContext:localContext];
//        } completion:^(BOOL success, NSError *error) {
//            
//            
//            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//                
//                NSDictionary *art = [JSON objectForKey:@"art"];
//                Art *artRecord = [Art MR_findFirstByAttribute:@"artID" withValue:[art objectForKey:@"slug"] inContext:localContext];
//                
//                //add categories
//                if ([[art objectForKey:@"category"] isKindOfClass:[NSArray class]]) {
//                    
//                    for (NSString *thisCatTitle in [art objectForKey:@"category"]) {
//                        
//                        Category *catObject = [Category MR_findFirstByAttribute:@"categoryID" withValue:thisCatTitle];
//                        if (catObject) {
//                            [artRecord addCategoriesObject:catObject];
//                        }
//                        
//                    }
//                    
//                }
//                
//                //add photos
//                if ([[art objectForKey:@"photos"] isKindOfClass:[NSArray class]]) {
//                    
//                    NSArray *photoObjects = [Photo MR_importFromArray:[art objectForKey:@"photos"] inContext:localContext];
//                    NSSet *photosSet = [[NSSet alloc] initWithArray:photoObjects];
//                    [artRecord addPhotos:photosSet];
//                    
//                    //for (NSDictionary *thisPhotoDict in [art objectForKey:@"photos"]) {
//                    //}
//                    
//                }
//                
//            } completion:^(BOOL success, NSError *error) {
//                
//                #pragma clang diagnostic push
//                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//                    [(id)target performSelector:callback withObject:nil];
//                #pragma clang diagnostic pop
//                
//                [[Utilities instance] stopActivity];
//                
//            }];
//            
//            
//        }];
//        
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        
//        DebugLog(@"Download art failed. Error: %@.  JSON: %@", error, JSON);
//        
//        #pragma clang diagnostic push
//        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            [(id)target performSelector:callback withObject:nil];
//        #pragma clang diagnostic pop
//        
//    }];
//    [request start];

}


#pragma mark - Art Upload Methods
- (void)submitArt:(NSDictionary*)art withTarget:(id)target callback:(SEL)callback failCallback:(SEL)failCallback {
    
    //TODO: test this.  Originally it was a POST request with a param "_method" with a value of "put".  So maybe I need to re-add that param and switch the request type back to POST.
    
    //setup the art's paramters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:art];
//    [params setObject:@"put" forKey:@"_method"];
   
    //start network activity indicator
	[[Utilities instance] startActivity];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager PUT:[AAAPIManager apiURLForMethod:@"arts"].absoluteString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (target && [target respondsToSelector:callback]) {
            [target performSelectorOnMainThread:callback withObject:responseObject waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (target && [target respondsToSelector:failCallback]) {
            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
    }];
    
//    NSString *baseUrl = [[NSString alloc] initWithFormat:@"%@", _kAPIRoot];
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
//    [client putPath:@"arts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        if (target && [target respondsToSelector:callback]) {
//            [target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        if (target && [target respondsToSelector:failCallback]) {
//            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    }];
    
}

//update art (put method)
- (void)updateArt:(NSMutableDictionary*)art withTarget:(id)target callback:(SEL)callback failCallback:(SEL)failCallback {
    
    //setup the art's paramters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:art];
    
    //start network activity indicator
	[[Utilities instance] startActivity];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager PUT:[AAAPIManager apiURLForMethod:[NSString stringWithFormat:@"arts/%@", [art objectForKey:@"slug"], nil]].absoluteString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (target && [target respondsToSelector:callback]) {
            [target performSelectorOnMainThread:callback withObject:responseObject waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (target && [target respondsToSelector:failCallback]) {
            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
    }];
    
//    NSString *baseUrl = [[NSString alloc] initWithFormat:@"%@", _kAPIRoot];
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
//    [client putPath:[NSString stringWithFormat:@"arts/%@", [art objectForKey:@"slug"]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        if (target && [target respondsToSelector:callback]) {
//            [target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        if (target && [target respondsToSelector:failCallback]) {
//            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    }];

    
}


//adds an image to a piece of art
// -- a slug is required
- (void)uploadImage:(UIImage*)image forSlug:(NSString*)slug withFlickrHandle:(NSString*)flickrHandle withPhotoAttributionURL:(NSString*)photoAttributionURL withTarget:(id)target callback:(SEL)callback failCallback:(SEL)failCallback {
    
    //get the photo upload url
    NSURL *photoUploadURL = [AAAPIManager apiURLForMethod:[NSString stringWithFormat:@"arts/%@/photos", slug]];
    
    //start network activity indicator
	[[Utilities instance] startActivity];
	
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 0.5)];
    NSData *attributionNameData = [flickrHandle dataUsingEncoding:NSUTF8StringEncoding];
    NSData *attributionUrlData = [photoAttributionURL dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:photoUploadURL.absoluteString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"file.jpeg" mimeType:@"image/jpeg"];
        [formData appendPartWithFormData:attributionNameData name:@"photo_attribution_text"];
        [formData appendPartWithFormData:attributionUrlData name:@"photo_attribution_url"];
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (target && [target respondsToSelector:callback]) {
            [target performSelectorOnMainThread:callback withObject:responseObject waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (target && [target respondsToSelector:failCallback]) {
            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];

    }];

    
    
    
	//pass along target and selector in userInfo
//	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:target, _kTargetKey, [NSValue valueWithPointer:callback], _kCallbackKey, [NSValue valueWithPointer:failCallback], _kFailCallbackKey, nil];

    
    //--create the post body
    //----
    
//    NSString *filename = @"file";
//    NSString *boundary = @"---------------------------14737809831466499882746641449";
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
//    
//    NSMutableData *postbody = [NSMutableData data];
//    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    //add image
//    NSString *formDataString = [[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpeg\"\r\n", filename];
//    [postbody appendData:[formDataString dataUsingEncoding:NSUTF8StringEncoding]];
//    DebugLog(@"Form Data: %@", formDataString);
//    [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postbody appendData:[NSData dataWithData:UIImageJPEGRepresentation(image, 0.5)]];
//    
//    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//   
//    NSString *attString = [[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"photo_attribution_text\"\r\n\r\n%@", flickrHandle];
//    [postbody appendData:[attString dataUsingEncoding:NSUTF8StringEncoding]];
//
//    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSString *attURLString = [[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"photo_attribution_url\"\r\n\r\n%@", photoAttributionURL];
//    [postbody appendData:[attURLString dataUsingEncoding:NSUTF8StringEncoding]];
//    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
//    NSString *baseUrl = [[NSString alloc] initWithFormat:@"%@", _kAPIRoot];
//    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
//    [client requestWithMethod:@"POST" path:[NSString stringWithFormat:@"arts/%@/photos", slug] parameters:nil];
//    [client postPath:[NSString stringWithFormat:@"arts/%@/photos", slug] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        if (target && [target respondsToSelector:callback]) {
//            [target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        if (target && [target respondsToSelector:failCallback]) {
//            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
//        }
//        
//        [[Utilities instance] stopActivity];
//        
//    }];

    
    
    //setup and start the request
//	ASIHTTPRequest *request = [self requestWithURL:photoUploadURL userInfo:userInfo];
//    [request setRequestMethod:@"POST"];
//    [request addRequestHeader:@"Content-Type" value:contentType];
//    [request setTimeOutSeconds:45];
//    [request setNumberOfTimesToRetryOnTimeout:0];
//    [request setPostBody:postbody];
//	[request setDidFinishSelector:@selector(artUploadCompleted:)];
//	[request setDidFailSelector:@selector(artUploadFailed:)];
//	[request startAsynchronous];


       
}

/*
- (void)artUploadCompleted:(id)request
{
    
    //deserialize the json response
	NSError *jsonError = nil;
	NSDictionary *responseDict = [[request responseData] objectFromJSONDataWithParseOptions:JKParseOptionNone error:&jsonError];
	
	//check for an error
	if (jsonError || !responseDict) {
		DebugLog(@"artUploadCompleted error: %@", jsonError);
        
        //call the selector on the target if applicable and pass the responseDict
        NSDictionary *userInfo = [request userInfo];
        if (userInfo) {
            id target = [userInfo objectForKey:_kTargetKey];
            SEL callback = [[userInfo objectForKey:_kCallbackKey] pointerValue];
            if (target && [target respondsToSelector:callback]) {
                [target performSelectorOnMainThread:callback withObject:responseDict waitUntilDone:NO];
            }
        }
        
        [[Utilities instance] stopActivity];
        
		return;
	}
    
    //call the selector on the target if applicable and pass the responseDict
	NSDictionary *userInfo = [request userInfo];
	if (userInfo) {
		id target = [userInfo objectForKey:_kTargetKey];
 		SEL callback = [[userInfo objectForKey:_kCallbackKey] pointerValue];
		if (target && [target respondsToSelector:callback]) {
			[target performSelectorOnMainThread:callback withObject:responseDict waitUntilDone:NO];
		}
	}
    
	//stop network activity indicator
	[[Utilities instance] stopActivity];
}

- (void)artUploadFailed:(id)request
{
	DebugLog(@"artUploadFailed");
    
	
    //call the selector on the target if applicable
	NSDictionary *userInfo = [request userInfo];
	if (userInfo) {
		id target = [userInfo objectForKey:_kTargetKey];
 		SEL callback = [[userInfo objectForKey:_kFailCallbackKey] pointerValue];
		if (target && [target respondsToSelector:callback]) {
			[target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
		}
	}
    
	//stop network activity indicator
	[[Utilities instance] stopActivity];
}
*/

#pragma mark - Comment Upload
//upload the comment dictionary
- (void)uploadComment:(NSDictionary*)commentDictionary forSlug:(NSString*)slug target:(id)target callback:(SEL)callback failCallback:(SEL)failCallback
{
    
    //setup the art's paramters
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if ([[commentDictionary objectForKey:@"name"] length] > 0) {
        [params setValue:[Utilities urlEncode:[commentDictionary objectForKey:@"name"]] forKey:@"name"];
    }
    
    if ([[commentDictionary objectForKey:@"url"] length] > 0) {
        [params setValue:[Utilities urlEncode:[commentDictionary objectForKey:@"url"]] forKey:@"url"];
    }
    
    if ([[commentDictionary objectForKey:@"email"] length] > 0) {
        [params setValue:[Utilities urlEncode:[commentDictionary objectForKey:@"email"]] forKey:@"email"];
    }
    
    if ([[commentDictionary objectForKey:@"text"] length] > 0) {
        [params setValue:[Utilities urlEncode:[commentDictionary objectForKey:@"text"]] forKey:@"text"];
    }
    
    
    //get the art upload url
    NSURL *commentUploadURL = [AAAPIManager apiURLForMethod:[NSString stringWithFormat:@"arts/%@/comments", slug, nil] parameters:params];
    
    //start network activity indicator
	[[Utilities instance] startActivity];
	
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:commentUploadURL.absoluteString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (target && [target respondsToSelector:callback]) {
            [target performSelectorOnMainThread:callback withObject:responseObject waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (target && [target respondsToSelector:failCallback]) {
            [target performSelectorOnMainThread:failCallback withObject:nil waitUntilDone:NO];
        }
        
        [[Utilities instance] stopActivity];
        
    }];
    
}

/*
//comment upload callback
- (void)commentUploadCompleted:(id)request
{
    
    //deserialize the json response
	NSError *jsonError = nil;
	NSDictionary *responseDict = [[request responseData] objectFromJSONDataWithParseOptions:JKParseOptionNone error:&jsonError];
	
	//check for an error
	if (jsonError || !responseDict) {
		DebugLog(@"commentUploadCompleted error: %@", jsonError);
        
        //call the selector on the target if applicable
        NSDictionary *userInfo = [request userInfo];
        if (userInfo) {
            id target = [userInfo objectForKey:_kTargetKey];
            SEL callback = [[userInfo objectForKey:_kFailCallbackKey] pointerValue];
            if (target && [target respondsToSelector:callback]) {
                [target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
            }
        }
        
        [[Utilities instance] stopActivity];        
        
		return;
	}
    
    //call the selector on the target if applicable and pass the responseDict
	NSDictionary *userInfo = [request userInfo];
	if (userInfo) {
		id target = [userInfo objectForKey:_kTargetKey];
 		SEL callback = [[userInfo objectForKey:_kCallbackKey] pointerValue];
		if (target && [target respondsToSelector:callback]) {
			[target performSelectorOnMainThread:callback withObject:responseDict waitUntilDone:NO];
		}
	}
    
	//stop network activity indicator
	[[Utilities instance] stopActivity];
}

//coment upload fail callback
- (void)commentUploadFailed:(id)request
{
	DebugLog(@"commentUploadFailed");
    
    //call the selector on the target if applicable
	NSDictionary *userInfo = [request userInfo];
	if (userInfo) {
		id target = [userInfo objectForKey:_kTargetKey];
 		SEL callback = [[userInfo objectForKey:_kFailCallbackKey] pointerValue];
		if (target && [target respondsToSelector:callback]) {
			[target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
		}
	}
    
	//stop network activity indicator
	[[Utilities instance] stopActivity];
}*/

#pragma mark - Helper Methods

/*- (id)requestWithURL:(NSURL *)url userInfo:(NSDictionary *)userInfo
{
    
	//setup and start the request
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setNumberOfTimesToRetryOnTimeout:1];
	[request setDelegate:self];
	[request setUserInfo:userInfo];
	
	return request;
}*/

#pragma mark - Class Methods

+ (AAAPIManager *)instance
{	
	@synchronized(self)	{
		//initialize the shared singleton if it has not yet been created
		if (_sharedInstance == nil)
			_sharedInstance = [[AAAPIManager alloc] init];
	}
	return _sharedInstance;
}

+ (NSManagedObjectContext *)managedObjectContext
{
	return nil;//[(ArtAroundAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	return nil;//[(ArtAroundAppDelegate *)[UIApplication sharedApplication].delegate persistentStoreCoordinator];
}

//makes sure a non-NSNull value is returned
+ (id)clean:(id)object
{
	if ([object isKindOfClass:[NSNull class]]) {
		return nil;
	}
	return object;
}

+ (BOOL)isCacheExpiredForURL:(NSURL *)url
{
	//default to 2 hours
	return [AAAPIManager isCacheExpiredForURL:url timeout:60 * 120];
}

+ (BOOL)isCacheExpiredForURL:(NSURL *)url timeout:(int)timeout
{
	//if a nil url was passed, quit now
	if (!url || [[url absoluteString] length] == 0) {
		return YES;
	}
	
	//convert the url to a key for EGOCache
	NSString *regexPattern = @"[/:.#]"; 
	NSString *key = [[url absoluteString] stringByReplacingOccurrencesOfString:regexPattern
										  withString:@"_"
										  options:NSRegularExpressionSearch | NSCaseInsensitiveSearch
										  range:NSMakeRange(0, [[url absoluteString] length])];
	
	//if cache exists, then it has not expired
	if ([[EGOCache globalCache] hasCacheForKey:key]) {
		return NO;
	}
	
	//cache didn't exist
	//return yes, the cache is expired
	//create a new cache entry
	[[EGOCache globalCache] setString:@"YES" forKey:key withTimeoutInterval:timeout];
	return YES;
}

+ (NSURL *)apiURLForMethod:(NSString *)method
{
	return [AAAPIManager apiURLForMethod:method parameters:nil];
}

+ (NSURL *)apiURLForMethod:(NSString *)method parameters:(NSDictionary *)parametersDict
{
	//setup the base url
	NSString *urlString = [NSString stringWithFormat:@"%@%@.%@", _kAPIRoot, method, _kAPIFormat];
	
	//add each parameter passed
	BOOL first = YES;
	for (NSString* key in parametersDict) {
        //if the key is location[] then split the lat/long out of the coordinate 
        if ([key isEqualToString:@"location[]"]) {
            urlString = [urlString stringByAppendingFormat:@"%@%@=%f&%@=%f", (first) ? @"?" : @"&", key, [(CLLocation*)[parametersDict objectForKey:key] coordinate].latitude, key, [(CLLocation*)[parametersDict objectForKey:key] coordinate].longitude];
        }
		else {
            NSString *value = [parametersDict objectForKey:key];
            urlString = [urlString stringByAppendingFormat:@"%@%@=%@", (first) ? @"?" : @"&", key, value];
        }
		
		first = NO;
	}
    
    //if ([urlString rangeOfString:@"photos.json"].location != NSNotFound)
    //    urlString = [urlString stringByAppendingString:@"?attribution_text=attTextHere&attribution_url=google"];
	
	DebugLog(@"URL Requested: %@", urlString);
	
	//return the fully formed url
	return [NSURL URLWithString:urlString];
}

@end
