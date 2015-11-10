//
//  TagParser.m
//  ArtAround
//
//  Created by Samosys on 22/08/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import "TagParser.h"
#import "JSONKit.h"
@implementation TagParser


+ (NSSet *)setForTitles:(NSArray *)tagTitles inContext:(NSManagedObjectContext *)context
{
    NSMutableSet *tages = [NSMutableSet set];
    for (NSString *title in tagTitles) {
        
        //get the category for the given title
        //add cateogry to the set
        Tag *tag = [TagParser tagForTitle:title inContext:context];
        [tages addObject:tag];
        
    }
    return tages;
}

+ (Tag *)tagForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context
{
    //get or create a category with the given title.
    Tag *tag = [ItemParser existingEntity:@"Tag" inContext:context uniqueKey:@"title" uniqueValue:title];
    if (!tag) {
        tag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        
        NSString *arrayTitle = @"";
        if ([title isKindOfClass:[NSArray class]])
            arrayTitle = [(NSArray*)title componentsJoinedByString:@", "];
        else
            arrayTitle = title;
        
        tag.title = [AAAPIManager clean:arrayTitle];
    }
    return tag;
}

+ (NSArray *)arrayFortagRequest:(ASIHTTPRequest *)tagRequest
{
    //deserialize the json response
    NSError *error = nil;
    NSArray *tages = [[tagRequest responseData] objectFromJSONDataWithParseOptions:JKParseOptionNone error:&error];
    
    //check for an error
    if (error || !tages) {
        DebugLog(@"arrayForCategoryRequest error: %@", error);
    }
    
    return tages;
}

@end
