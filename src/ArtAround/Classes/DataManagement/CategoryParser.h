//
//  CategoryParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Category.h"
#import "ItemParser.h"

@interface CategoryParser : ItemParser

+ (NSSet *)setForTitles:(NSArray *)categoryTitles inContext:(NSManagedObjectContext *)context;
+ (Category *)categoryForTitle:(NSString *)title inContext:(NSManagedObjectContext *)context;
+ (NSArray *)arrayForCategoryRequest:(ASIHTTPRequest *)categoryRequest;

@end
