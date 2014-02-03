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

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL shouldShowHiddenItem;

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
    self.title = self.selectedPhotoDescription;
    self.shouldShowHiddenItem = YES;
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    self.scrollView.delegate = self;
    //Add Tap gesture support
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerTapEvent:)];
    singleFingerTap.numberOfTouchesRequired = 1;
    singleFingerTap.numberOfTapsRequired = 1;
    singleFingerTap.delegate = self;
    [self.imageView addGestureRecognizer:singleFingerTap];
    //Make up the UI
    self.imageView.userInteractionEnabled = YES;
    self.imageView.multipleTouchEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.tabBarController.tabBar.hidden = YES;
    [self.spinner startAnimating];
    
    [[TopPlacesModelLayer sharedModelLayer] addObserver:self forKeyPath:@"downloadedPhoto" options:NSKeyValueObservingOptionNew context:kDownloadedPhoto];
    [[TopPlacesModelLayer sharedModelLayer] downloadPhotoWithPhotoIndex:self.selectedPhotoIndex];
    [[TopPlacesModelLayer sharedModelLayer] updateViewHistory:self.selectedPhotoIndex];
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
                //Init the imageView based on the downloaded image
                [self.spinner stopAnimating];
                [self.imageView setImage:[[TopPlacesModelLayer sharedModelLayer] downloadedPhoto]];
                self.navigationController.navigationBarHidden = YES;
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

#pragma imageView UITapGestureRecognizer delegate method

- (void) handleSingleFingerTapEvent:(UITapGestureRecognizer *) sender {
    if (self.shouldShowHiddenItem) {
        self.shouldShowHiddenItem = NO;
        self.tabBarController.tabBar.hidden = NO;
        self.navigationController.navigationBarHidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    else {
        self.shouldShowHiddenItem = YES;
        self.tabBarController.tabBar.hidden = YES;
        self.navigationController.navigationBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

@end
