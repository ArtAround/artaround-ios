//
//  AAManagedObjectContext.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import <Foundation/Foundation.h>

@interface AAManagedObjectContext : NSManagedObjectContext {
	NSDictionary *_userInfo;
}

@property (nonatomic, retain) NSDictionary *userInfo;

@end
