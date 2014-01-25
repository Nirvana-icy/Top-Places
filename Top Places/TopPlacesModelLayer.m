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

- (void)queryTopPlacesInFlickr
{
    //Send the async request to Flickr
    NSURLRequest *request = [NSURLRequest requestWithURL:[FlickrFetcher URLforTopPlaces]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError){
         if (connectionError)   NSLog(@"Http Error:%@ %d", connectionError.localizedDescription, connectionError.code);
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

@end
