//
//  ArtAnnotation.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ArtAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
	NSString *_subtitle;
	NSString *_title;
	NSInteger _index;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) NSInteger index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate title:(NSString *)theTitle subtitle:(NSString *)theSubTitle;

@end
