//
//  TopPlacePhotoDisplayViewController.m
//  Top Places
//
//  Created by Nirvana on 14-1-26.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import "TopPlacePhotoDisplayViewController.h"
#import "TopPlacesModelLayer.h"

static void *kDownloadedPhoto = &kDownloadedPhoto;

@interface TopPlacePhotoDisplayViewController ()

@end

@implementation TopPlacePhotoDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[TopPlacesModelLayer sharedModelLayer] addObserver:self forKeyPath:@"downloadedPhoto" options:NSKeyValueObservingOptionNew context:kDownloadedPhoto];
    [[TopPlacesModelLayer sharedModelLayer] downloadPhotoWithPhotoIndex:self.selectedPhotoIndex];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[TopPlacesModelLayer sharedModelLayer] removeObserver:self forKeyPath:@"downloadedPhoto"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma KVO callback method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (kDownloadedPhoto == context) {
        if ([TopPlacesModelLayer sharedModelLayer].downloadedPhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //After download the photo image
                //Init the imageView based on the downloaded image
                [self.imageView setImage:[[TopPlacesModelLayer sharedModelLayer] downloadedPhoto]];
                //Set the scollView.contentSize = image.size
                self.scrollView.contentSize = [[TopPlacesModelLayer sharedModelLayer] downloadedPhoto].size;
                //Set the default zoom scale
                float delta = 1;
                if (self.scrollView.contentSize.width >= self.scrollView.contentSize.height)
                    delta = ([UIScreen mainScreen].scale*[[UIScreen mainScreen] bounds].size.width)/self.scrollView.contentSize.width;
                else
                    delta = ([UIScreen mainScreen].scale*[[UIScreen mainScreen] bounds].size.height)/self.scrollView.contentSize.height;
                
                [self.scrollView setZoomScale:delta];
                //Set imageView's center to the center of scrollView
                
                //Hidden loading view
                [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.loadingView.alpha = 0;
                }completion:^(BOOL finished){
                    [self.loadingView setHidden:YES];
                }];
            });
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma UIScrollViewDelegate method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //Set the center of imageView to the center of the scrollView
}

@end
