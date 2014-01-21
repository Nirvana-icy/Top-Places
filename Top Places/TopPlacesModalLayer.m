//
//  TopPlacesModalLayer.m
//  Top Places
//
//  Created by Nirvana on 14-1-21.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import "TopPlacesModalLayer.h"
#import "FlickrFetcher.h"

@implementation TopPlacesModalLayer

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
             
             NSString *countryIndex[[topPlacesArray count]];
             for (int i = 0; i < [topPlacesArray count]; i++) {
                 //get the place content string from one places dict union
                 NSString *placeContentString = [topPlacesArray valueForKeyPath:FLICKR_PLACE_NAME];
                 //Divided the string  "_content" = "Shanghai, Shanghai, China" to @["Shanghai","Shanghai","China"]
                 NSArray *placeContentStringItems = [placeContentString componentsSeparatedByString:@", "];
                 //get the country name from the string _content
                 countryIndex[i] = [(NSString *)[placeContentStringItems lastObject] stringByAppendingFormat:@"+%d", i];
             }
             _countryIndexArray = [NSArray arrayWithObjects:countryIndex count:[topPlacesArray count]];
             NSLog(@"countryIndexArray %@", _countryIndexArray);
         }
     }];
}

@end
