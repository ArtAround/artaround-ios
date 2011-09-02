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
#import "ASIHTTPRequest.h"
#import "ArtAroundAppDelegate.h"
#import "CJSONDeserializer.h"
#import "Art.h"
#import "Category.h"
#import "Neighborhood.h"
#import "ArtParser.h"
#import "ConfigParser.h"
#import "EGOCache.h"

static AAAPIManager *_sharedInstance = nil;
static const NSString *_kAPIRoot = @"http://theartaround.us/api/v1/";
static const NSString *_kAPIFormat = @"json";
static const NSString *_kTargetKey = @"target";
static const NSString *_kCallbackKey = @"callback";

//private methods
@interface AAAPIManager (private)
- (ASIHTTPRequest *)requestWithURL:(NSURL *)url userInfo:(NSDictionary *)userInfo;
- (ASIHTTPRequest *)downloadNeighborhoods;
- (ASIHTTPRequest *)downloadCategories;
- (NSArray *)arrayForSQL:(char *)sql;
+ (BOOL)isCacheExpiredForURL:(NSURL *)url;
+ (BOOL)isCacheExpiredForURL:(NSURL *)url timeout:(int)timeout;
+ (NSURL *)apiURLForMethod:(NSString *)method;
+ (NSURL *)apiURLForMethod:(NSString *)method parameters:(NSDictionary *)parametersDict;
@end

@implementation AAAPIManager

- (void)itemParserContextDidSave:(NSNotification *)notification
{	
	//merge core data changes on the main thread
	[self performSelectorOnMainThread:@selector(mergeChanges:) withObject:notification waitUntilDone:YES];
	
	//call the selector on the target if applicable
	NSDictionary *userInfo = [[notification object] userInfo];
	if (userInfo) {
		id target = [userInfo objectForKey:_kTargetKey];
 		SEL callback = [[userInfo objectForKey:_kCallbackKey] pointerValue];
		if (target && [target respondsToSelector:callback]) {
			[target performSelectorOnMainThread:callback withObject:nil waitUntilDone:NO];
		}
	}
}

//merges changes from other managed object context
- (void)mergeChanges:(NSNotification *)notification
{	
	[[AAAPIManager managedObjectContext] lock];
	[[AAAPIManager persistentStoreCoordinator] lock];
	[[AAAPIManager managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
	NSError *error = nil;
	if (![[AAAPIManager managedObjectContext] save:&error] || error) {
		DebugLog(@"Error saving after merge to the database: %@, %@", error, [error userInfo]);
	}
	[[AAAPIManager persistentStoreCoordinator] unlock];
	[[AAAPIManager managedObjectContext] unlock];
}

- (void)dealloc
{
	[super dealloc];
}

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
	return [self arrayForSQL:"SELECT DISTINCT ZTITLE FROM ZCATEGORY WHERE ZTITLE IS NOT NULL ORDER BY ZTITLE"];
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

#pragma mark - Config (aka Categories & Neighborhoods) Download Methods

- (void)downloadConfigWithTarget:(id)target callback:(SEL)callback
{	
	//cache for 1 week
	int timeout = 60 * 60 * 24 * 7;
	
	//if both neighborhoods and categories are cached, quit now
	if (![AAAPIManager isCacheExpiredForURL:[AAAPIManager apiURLForMethod:@"neighborhoods"] timeout:timeout] &&
		![AAAPIManager isCacheExpiredForURL:[AAAPIManager apiURLForMethod:@"categories"] timeout:timeout]) {
		return;
	}
	
	//pass along target and selector in userInfo
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:target, _kTargetKey, [NSValue valueWithPointer:callback], _kCallbackKey, nil];
	
	//download everything
	ASIHTTPRequest *categoryRequest = [self downloadCategories];
	ASIHTTPRequest *neighborhoodRequest = [self downloadNeighborhoods];

	//parse the config items
	ConfigParser *parser = [[ConfigParser alloc] init];
	[parser parseCategoryRequest:categoryRequest neighborhoodRequest:neighborhoodRequest userInfo:userInfo];
	[parser autorelease];
}

- (ASIHTTPRequest *)downloadNeighborhoods
{
	//setup and start the request
	ASIHTTPRequest *request = [self requestWithURL:[AAAPIManager apiURLForMethod:@"neighborhoods"] userInfo:nil];
	[request startSynchronous];
	
	return request;
}

- (ASIHTTPRequest *)downloadCategories
{
	//setup and start the request
	ASIHTTPRequest *request = [self requestWithURL:[AAAPIManager apiURLForMethod:@"categories"] userInfo:nil];
	[request startSynchronous];
	
	return request;
}

#pragma mark - Art Download Methods

//todo: possibly add a BOOL:force parameter so that we can force refresh if needed
- (void)downloadAllArtWithTarget:(id)target callback:(SEL)callback
{
	//get the all art url
	NSDictionary *params = [NSDictionary dictionaryWithObject:@"9999" forKey:@"per_page"];
	NSURL *allArtURL = [AAAPIManager apiURLForMethod:@"arts" parameters:params];
	
	//if art is cached, quit now
	//cache for 24 hours
	if (![AAAPIManager isCacheExpiredForURL:allArtURL timeout:60 * 60 * 24]) {
		return;
	}
	
	//pass along target and selector in userInfo
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:target, _kTargetKey, [NSValue valueWithPointer:callback], _kCallbackKey, nil];
	
	//setup and start the request
	//todo: revisit this - may need to adjust how we download if too many items are being downloaded
	ASIHTTPRequest *request = [self requestWithURL:allArtURL userInfo:userInfo];
	[request setDidFinishSelector:@selector(artRequestCompleted:)];
	[request setDidFailSelector:@selector(artRequestFailed:)];
	[request startAsynchronous];
}

- (void)artRequestCompleted:(ASIHTTPRequest *)request
{
	//parse the art in the background
	[self performSelectorInBackground:@selector(parseArtRequest:) withObject:request];
}

- (void)parseArtRequest:(ASIHTTPRequest *)request
{
	//in the background, use a pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	//parse the art
	ArtParser *parser = [[ArtParser alloc] init];
	[parser parseRequest:request];
	[parser autorelease];
	
	//release the pool
	[pool release];
}

- (void)artRequestFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"artRequestFailed");
}

#pragma mark - Helper Methods

- (ASIHTTPRequest *)requestWithURL:(NSURL *)url userInfo:(NSDictionary *)userInfo
{
	//setup and start the request
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setNumberOfTimesToRetryOnTimeout:1];
	[request setDelegate:self];
	[request setUserInfo:userInfo];
	
	return request;
}

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
	return [(ArtAroundAppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	return [(ArtAroundAppDelegate *)[UIApplication sharedApplication].delegate persistentStoreCoordinator];
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
	if ([[EGOCache currentCache] hasCacheForKey:key]) {
		return NO;
	}
	
	//cache didn't exist
	//return yes, the cache is expired
	//create a new cache entry
	[[EGOCache currentCache] setString:@"YES" forKey:key withTimeoutInterval:timeout];
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
		NSString *value = [parametersDict objectForKey:key];
		urlString = [urlString stringByAppendingFormat:@"%@%@=%@", (first) ? @"?" : @"&", key, value];
		first = NO;
	}
	
	DebugLog(@"URL Requested: %@", urlString);
	
	//return the fully formed url
	return [NSURL URLWithString:urlString];
}

@end
