//
//  Utilities.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "Utilities.h"

static Utilities *_kSharedInstance = nil;

@interface Utilities (private)
- (NSString *)keyForFilterType:(FilterType)filterType;
@end

@implementation Utilities
@synthesize selectedFilterType = _selectedFilterType;

//singleton
+ (Utilities *)instance
{	
	@synchronized(self)	{
		if (_kSharedInstance == nil)
			_kSharedInstance = [[Utilities alloc] init];
	}
	return _kSharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) {

		//used to get settings from nsuserdefaults in various properties below
		_defaults = [NSUserDefaults standardUserDefaults];
		
		//set an invalid filter type so it is forced to pull from NSUserDefaults on first load
		_selectedFilterType = -1;

	}
	return self;
}

#pragma mark - Filter Methods

- (void)setSelectedFilterType:(FilterType)aFilterType
{
	_selectedFilterType = aFilterType;
	[_defaults setInteger:aFilterType forKey:@"AAFilterType"];
}

- (FilterType)selectedFilterType
{
	if (_selectedFilterType == -1) {
		_selectedFilterType = [_defaults integerForKey:@"AAFilterType"];
	}
	return _selectedFilterType;
}

- (NSArray *)getFiltersForFilterType:(FilterType)filterType
{
	return [_defaults objectForKey:[self keyForFilterType:filterType]];
}

- (void)setFilters:(NSArray *)filters forFilterType:(FilterType)filterType
{
	//if no filters, remove all other filters
	//else set the filters
	if (filterType == FilterTypeNone) {
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeCategory]];
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeNeighborhood]];
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeArtist]];
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeTitle]];
	} else {
		[_defaults setObject:filters forKey:[self keyForFilterType:filterType]];
	}
}

- (NSString *)keyForFilterType:(FilterType)filterType
{
	return [NSString stringWithFormat:@"AAFilters_%i", filterType];
}

@end
