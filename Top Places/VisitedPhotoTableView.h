//
//  ViewedPhotoTableView.h
//  Top Places
//
//  Created by Nirvana on 14-2-3.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitedPhotoTableView : UITableViewController

@property(nonatomic, strong) NSURL *selectPhotoURL;
@property(nonatomic, strong) NSString *selectedPhotoDescription;

@end
