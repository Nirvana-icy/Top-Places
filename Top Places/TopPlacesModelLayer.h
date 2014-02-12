//
//  TopPlacesModalLayer.h
//  Top Places
//
//  Created by Nirvana on 14-1-21.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopPlacesModelLayer : NSObject

@property(nonatomic, strong) __block NSDictionary *responseTopPlacesDict;  //root response dictionary
@property(nonatomic, strong) __block NSDictionary *countryIndexDict;
@property(nonatomic, strong) __block NSArray *photosDictArray;
@property(nonatomic, strong) __block UIImage *downloadedPhoto;
@property(nonatomic, strong) __block UIImage *downloadedPhotoVisited;
@property(nonatomic, strong) NSOperationQueue *networkRequestQueue;


@property(nonatomic, strong) NSMutableArray *viewedPhotoArray;

+ (instancetype) sharedModelLayer;

- (void)queryTopPlacesInFlickr;
- (void)queryPhotosOfSelectCityInFlickr:(id)flickrPlaceId maxResults:(int)maxResults;
- (void)downloadPhotoWithPhotoIndex:(NSInteger) photoIndex;
- (void)updateViewHistory:(NSInteger) photoIndex;
- (void)downloadPhotoWithPhotoURL:(NSURL *)photoURL;

@end
