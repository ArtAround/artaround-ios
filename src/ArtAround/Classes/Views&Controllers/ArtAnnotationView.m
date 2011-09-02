//
//  ArtAnnotationView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/31/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "ArtAnnotationView.h"

@implementation ArtAnnotationView
@synthesize preventSelectionChange = _preventSelectionChange;

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	
	/* todo: ios 3.0 support - will require more changes than this
	 #import "ArtAroundAppDelegate.h"
	 #import "MapViewController.h"
	 #import "MapView.h"
	//didSelectAnnotationView was added in ios 4 so we must manually call it for devices < 4.0
	//if < ios 4 (isMultitaskingSupported was added in ios 4)
	if (![[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
		ArtAroundAppDelegate *appDelegate = (ArtAroundAppDelegate *)[[UIApplication sharedApplication] delegate];
		MKMapView *mapView = appDelegate.mapViewController.mapView.map;
		if ([mapView.delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
			[mapView.delegate mapView:mapView didSelectAnnotationView:self];
		}
	}
	 */
}

@end
