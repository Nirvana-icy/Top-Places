//
//  TopPlacesModalLayer.m
//  Top Places
//
//  Created by Nirvana on 14-1-21.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import "TopPlacesModelLayer.h"
#import "FlickrFetcher.h"

@implementation TopPlacesModelLayer

+ (instancetype) sharedModelLayer
{
    static TopPlacesModelLayer *sharedModelLayer = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedModelLayer = [[TopPlacesModelLayer alloc] init];
    });
    
    return sharedModelLayer;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.networkRequestQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)queryTopPlacesInFlickr
{
    //Send the async request to Flickr
    NSURLRequest *request = [NSURLRequest requestWithURL:[FlickrFetcher URLforTopPlaces]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.networkRequestQueue completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError){
         if (connectionError)   NSLog(@"Http Error(queryTopPlacesInFlickr):%@ %d", connectionError.localizedDescription, connectionError.code);
         else {
             _responseTopPlacesDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             
             NSArray *topPlacesArray = [_responseTopPlacesDict valueForKeyPath:FLICKR_RESULTS_PLACES];
             
             NSString *countryIndexArray[[topPlacesArray count]];
             for (int i = 0; i < [topPlacesArray count]; i++) {
                 //get the place content string from one places dict
                 NSString *placeContentString = [topPlacesArray[i] valueForKeyPath:FLICKR_PLACE_NAME];
                 //Divided the string  "_content" = "Shanghai, Shanghai, China" to @["Shanghai","Shanghai","China"]
                 NSArray *placeContentStringItems = [placeContentString componentsSeparatedByString:@", "];
                 //get the country name from the string _content
                 countryIndexArray[i] = [[NSString alloc] initWithString:[(NSString *)[placeContentStringItems lastObject] stringByAppendingFormat:@"+%d", i]];
             }
             NSArray *tempArray = [NSArray arrayWithObjects:countryIndexArray count:[topPlacesArray count]];
             NSArray *sortedCountryIndexArray = [tempArray sortedArrayUsingSelector:@selector(localizedCompare:)];
             
             NSArray *countryIndexStringItems;
             NSArray *countryIndexStringItemsNext;
             NSMutableArray *indexArray = [[NSMutableArray alloc] init];
             NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
             
             for (int i = 0; i < [sortedCountryIndexArray count]; i++) {
                 countryIndexStringItems = [sortedCountryIndexArray[i] componentsSeparatedByString:@"+"];
                 if (i + 1 < [sortedCountryIndexArray count])
                     countryIndexStringItemsNext = [sortedCountryIndexArray[i+1] componentsSeparatedByString:@"+"];
                 else
                     countryIndexStringItemsNext = @[@"The Fack Country", @"0"];
                 
                 if ([[countryIndexStringItems firstObject] isEqualToString:[countryIndexStringItemsNext firstObject]]) {
                     [indexArray addObject:[countryIndexStringItems lastObject]];
                 }
                 else {
                     [indexArray addObject:[countryIndexStringItems lastObject]];
                     [tempDict setValue:[indexArray copy] forKey:[countryIndexStringItems firstObject]];
                     [indexArray removeAllObjects];
                 }
             }
             self.countryIndexDict = [NSDictionary dictionaryWithDictionary:tempDict];
         }
     }];
}

- (void)queryPhotosOfSelectCityInFlickr:(id)flickrPlaceId maxResults:(int)maxResults
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[FlickrFetcher URLforPhotosInPlace:flickrPlaceId maxResults:maxResults]];
    [NSURLConnection sendAsynchronousRequest:request queue:self.networkRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        if (connectionError) {
            NSLog(@"Http Error(queryPhotosOfSelectCityInFlickr):%@ %d", connectionError.localizedDescription, connectionError.code);
        }
        else {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (!self.photosDictArray) {
                self.photosDictArray = nil;
                self.photosDictArray = [NSArray arrayWithArray:[responseDict valueForKeyPath:FLICKR_RESULTS_PHOTOS]];
            }
            else {
                self.photosDictArray = [NSArray arrayWithArray:[responseDict valueForKeyPath:FLICKR_RESULTS_PHOTOS]];
            }
        }
    }];
}

- (void)downloadPhotoWithPhotoIndex:(NSInteger)photoIndex
{
    NSURL *requestURL = [FlickrFetcher URLforPhoto:[self.photosDictArray objectAtIndex:photoIndex]  format:FlickrPhotoFormatOriginal];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    [NSURLConnection sendAsynchronousRequest:request queue:self.networkRequestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        if (connectionError) {
            NSLog(@"Http Error(downloadPhotoWithPhotoIndex):%@ %d", connectionError.localizedDescription, connectionError.code);
            if (!self.downloadedPhoto) self.downloadedPhoto = nil;
            self.downloadedPhoto = [UIImage imageWithContentsOfFile:@"photo_download_error.png"];
        }
        else {
            if (!self.downloadedPhoto) self.downloadedPhoto = nil;
            self.downloadedPhoto = [UIImage imageWithData:data];
        }
    }];
}

- (void)updateViewHistory:(NSInteger) photoIndex
{
    NSUserDefaults *appDefault = [NSUserDefaults standardUserDefaults];
    if (nil == [appDefault objectForKey:@"viewedPhotoArray"]) {   //if we never visit appDefault before => set default value
        [appDefault setInteger:-1 forKey:@"index"];
        [appDefault setObject:self.viewedPhotoArray forKey:@"viewedPhotoArray"];
    }
    //read viewed history out from appDefault
    NSDictionary *viewingPhoto = [self.photosDictArray objectAtIndex:photoIndex];
    
    NSInteger index = [appDefault integerForKey:@"index"];
    self.viewedPhotoArray = [NSMutableArray arrayWithArray:[appDefault arrayForKey:@"viewedPhotoArray"]];
    //if top 20 recently viewed photo contain this viewingPhoto,set the viewingPhoto to the first of the array and re-array the array
    if([self.viewedPhotoArray containsObject:viewingPhoto]) {
        NSInteger i = [self.viewedPhotoArray indexOfObject:viewingPhoto]%20;
        for ( ; i < index; i++) {
            if (19 == i) {
                self.viewedPhotoArray[i] = self.viewedPhotoArray[0];
                i = 0;
            }
            self.viewedPhotoArray[i] = self.viewedPhotoArray[i+1];
        }
        self.viewedPhotoArray[index] = viewingPhoto;
    }
    //if top 20 recently viewed photo do not contain this viewingPhoto, add this viewing photo to the first of the array
    else {
        19 == index ? 0:index++;
        self.viewedPhotoArray[index] = viewingPhoto;
        [appDefault setInteger:index forKey:@"index"];
        [appDefault setObject:self.viewedPhotoArray forKey:@"viewedPhotoArray"];
    }
    NSLog(@"%@", self.viewedPhotoArray);
}

- (NSArray *)viewedPhotoArray
{
    if (!_viewedPhotoArray) {
        _viewedPhotoArray = [NSMutableArray arrayWithCapacity:20];
    }
    return _viewedPhotoArray;
}

@end
