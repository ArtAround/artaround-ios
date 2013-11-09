//
//  AAManagedObjectContext.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAManagedObjectContext : NSManagedObjectContext {
	NSDictionary *_userInfo;
}

@property (nonatomic, strong) NSDictionary *userInfo;

@end
