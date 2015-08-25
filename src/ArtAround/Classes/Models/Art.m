//
//  Art.m
//  ArtAround
//
//  Created by Samosys on 17/07/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import "Art.h"
#import "Category.h"
#import "Comment.h"
#import "Event.h"
#import "Neighborhood.h"
#import "Photo.h"


@implementation Art

@dynamic artDescription;
@dynamic artist;
@dynamic commissioned;
@dynamic commissionedBy;
@dynamic commissionedByLink;
@dynamic createdAt;
@dynamic distance;
@dynamic favorite;
@dynamic latitude;
@dynamic locationDescription;
@dynamic longitude;
@dynamic rank;
@dynamic slug;
@dynamic title;
@dynamic ward;
@dynamic website;
@dynamic year;
@dynamic tag;
@dynamic categories;
@dynamic comments;
@dynamic event;
@dynamic neighborhood;
@dynamic photos;


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
