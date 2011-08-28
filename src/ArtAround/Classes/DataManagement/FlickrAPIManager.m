//
//  FlickrAPIManager.m
//  ArtAround
//
//  Created by Brandon Jones on 8/28/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "FlickrAPIManager.h"
#import "ASIHTTPRequest.h"
#import "PhotoParser.h"

static FlickrAPIManager *_sharedInstance = nil;
static const NSString *_kAPIRoot = @"http://api.flickr.com/services/rest/";
static const NSString *_kAPIFormat = @"json";
static const NSString *_kTargetKey = @"target";
static const NSString *_kCallbackKey = @"callback";
static const NSString *_kFlickrIDKey = @"flickrID";

//private methods
@interface FlickrAPIManager (private)
- (NSURL *)apiURLForMethod:(NSString *)method;
- (NSURL *)apiURLForMethod:(NSString *)method parameters:(NSDictionary *)parametersDict;
- (ASIHTTPRequest *)requestWithURL:(NSURL *)url userInfo:(NSDictionary *)userInfo;
@end

@implementation FlickrAPIManager
@synthesize apiKey = _apiKey;

#pragma mark - Class Methods

+ (FlickrAPIManager *)instance
{	
	@synchronized(self)	{
		//initialize the shared singleton if it has not yet been created
		if (_sharedInstance == nil)
			_sharedInstance = [[FlickrAPIManager alloc] init];
	}
	return _sharedInstance;
}

+ (const NSString *)flickrIDKey
{
	return _kFlickrIDKey;
}

#pragma mark - Flickr Download Methods

- (void)downloadPhotoWithID:(NSNumber *)flickrID target:(id)target callback:(SEL)callback
{
	//pass along target and selector in userInfo
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:target, _kTargetKey, [NSValue valueWithPointer:callback], _kCallbackKey, flickrID, _kFlickrIDKey, nil];
	
	//setup and start the request
	NSDictionary *params = [NSDictionary dictionaryWithObject:[flickrID stringValue] forKey:@"photo_id"];
	ASIHTTPRequest *request = [self requestWithURL:[self apiURLForMethod:@"flickr.photos.getSizes" parameters:params] userInfo:userInfo];
	[request setDidFinishSelector:@selector(photoRequestCompleted:)];
	[request setDidFailSelector:@selector(photoRequestFailed:)];
	[request startAsynchronous];
}

- (void)photoRequestCompleted:(ASIHTTPRequest *)request
{
	//parse the art in the background
	[self performSelectorInBackground:@selector(parsePhotoRequest:) withObject:request];
}

- (void)parsePhotoRequest:(ASIHTTPRequest *)request
{
	//in the background, use a pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	
	//parse the art
	PhotoParser *parser = [[PhotoParser alloc] init];
	[parser parseRequest:request];
	[parser autorelease];
	
	//release the pool
	[pool release];
}

- (void)photoRequestFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"artRequestFailed");
}

#pragma mark - Helper Methods

- (NSURL *)apiURLForMethod:(NSString *)method
{
	return [self apiURLForMethod:method parameters:nil];
}

- (NSURL *)apiURLForMethod:(NSString *)method parameters:(NSDictionary *)parametersDict
{
	//setup the base url
	NSString *urlString = [NSString stringWithFormat:@"%@?method=%@&api_key=%@&format=%@&nojsoncallback=1", _kAPIRoot, method, self.apiKey, _kAPIFormat];
	
	//add each parameter passed
	for (NSString* key in parametersDict) {
		NSString *value = [parametersDict objectForKey:key];
		urlString = [urlString stringByAppendingFormat:@"&%@=%@", key, value];
	}
	
	DebugLog(@"Flickr URL Requested: %@", urlString);
	
	//return the fully formed url
	return [NSURL URLWithString:urlString];
}

- (ASIHTTPRequest *)requestWithURL:(NSURL *)url userInfo:(NSDictionary *)userInfo
{
	//setup and start the request
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setNumberOfTimesToRetryOnTimeout:1];
	[request setDelegate:self];
	[request setUserInfo:userInfo];
	
	return request;
}

@end
