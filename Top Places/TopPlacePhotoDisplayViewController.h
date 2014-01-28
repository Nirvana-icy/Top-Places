//
//  TopPlacePhotoDisplayViewController.h
//  Top Places
//
//  Created by Nirvana on 14-1-26.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopPlacePhotoDisplayViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, assign) NSInteger selectedPhotoIndex;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (nonatomic) BOOL shouldShowHiddenItem;

@end
