//
//  ArtistParser.m
//  ArtAround
//
//  Created by samosys on 20/02/16.
//  Copyright © 2016 ArtAround. All rights reserved.
//

#import "ArtistParser.h"
#import "JSONKit.h"
@implementation ArtistParser

+ (NSSet *)setForTitles:(NSArray *)artistTitles inContext:(NSManagedObjectContext *)context
{
    NSMutableSet *tages = [NSMutableSet set];
    for (NSString *title in artistTitles) {
        
        //get the category for the given title
        //add cateogry to the set
        Artist *tag = [ArtistParser artistForTitle:title inContext:context];
        [tages addObject:tag];
        
    }
    return tages;
}

+ (Artist *)artistForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context{
    //get or create a category with the given title.
    Artist *tag = [ItemParser existingEntity:@"Artist" inContext:context uniqueKey:@"title" uniqueValue:title];
    if (!tag) {
        tag = (Artist *)[NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
        
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
