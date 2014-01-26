//
//  TopPlacesPhotoListTableViewController.h
//  Top Places
//
//  Created by Nirvana on 14-1-25.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrFetcher.h"
#import "TopPlacesModelLayer.h"

@interface TopPlacesPhotoListTableViewController : UITableViewController

@property(nonatomic, assign) NSInteger placeIndexInPlacesArray;
@property(nonatomic, strong) NSDictionary *selectCityDict;
@property(nonatomic, strong) __block NSArray *topCityPhotoInfoDictArray;
@property(nonatomic, assign) NSInteger selectedPhotoIndex;

@end
