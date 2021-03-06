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
@property(nonatomic, strong) NSString *selectedPhotoDescription;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL shouldShowHiddenItem;

@end
