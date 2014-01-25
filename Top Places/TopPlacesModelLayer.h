//
//  TopPlacesModalLayer.h
//  Top Places
//
//  Created by Nirvana on 14-1-21.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopPlacesModelLayer : NSObject

@property(nonatomic, strong) __block NSDictionary *responseTopPlacesDict;
@property(nonatomic, strong) __block NSDictionary *countryIndexDict;

+ (instancetype) sharedModelLayer;
- (void)queryTopPlacesInFlickr;

@end
