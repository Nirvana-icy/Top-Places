//
//  VisitedPhotoDisplayViewController.h
//  Top Places
//
//  Created by Nirvana on 14-2-12.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitedPhotoDisplayViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, strong) NSURL *selectPhotoURL;
@property(nonatomic, strong) NSString *selectedPhotoDescription;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL shouldShowHiddenItem;

@end
