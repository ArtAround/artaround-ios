//
//  Art.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright (c) 2011 ArtAround. All rights reserved.
//

#import "Art.h"
#import "Category.h"
#import "Comment.h"
#import "Neighborhood.h"
#import "Photo.h"
#import "Event.h"

@implementation Art
@dynamic artist;
@dynamic artDescription;
@dynamic createdAt;
@dynamic latitude;
@dynamic locationDescription;
@dynamic longitude;
@dynamic slug;
@dynamic title;
@dynamic ward;
@dynamic year;
@dynamic categories;
@dynamic comments;
@dynamic neighborhood;
@dynamic photos;
@dynamic favorite;
@dynamic distance;
@dynamic rank;
@dynamic commissioned;
@dynamic event;

- (NSString*)categoriesString
{
    NSString *catString = @"";
    NSArray *catArray = [self.categories allObjects];

    NSMutableArray *catTitlesArray = [[NSMutableArray alloc] initWithCapacity:catArray.count];
    
    for (Category *thisCat in catArray) {
        [catTitlesArray addObject:thisCat.title];
    }
    
    if (catTitlesArray.count > 0)
        catString = [catTitlesArray componentsJoinedByString:@", "];
    
    return catString;
}

@end
