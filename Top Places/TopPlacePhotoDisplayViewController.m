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
@property (strong, nonatomic) UIImageView *imageView;
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

- (UIImageView *) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = self.selectedPhotoDescription;
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
                //Stop the animation of the spinner
                [self.spinner stopAnimating];
                //Calc the zoom scale
                self.scrollView.contentSize = [[TopPlacesModelLayer sharedModelLayer] downloadedPhoto].size;
                float scaleInWidth = self.scrollView.frame.size.width/[[TopPlacesModelLayer sharedModelLayer] downloadedPhoto].size.width;
                float scaleInHeight = self.scrollView.frame.size.height/[[TopPlacesModelLayer sharedModelLayer] downloadedPhoto].size.height;
                //Init the imageView based on the downloaded image
                float offsetX = 0.0;
                float offsetY = 0.0;
                if (scaleInWidth == MIN(scaleInWidth, scaleInHeight)) {
                    scaleInWidth = scaleInWidth > 10.0 ? 10.0:scaleInWidth;
                    offsetX = 0.0;
                    offsetY = ABS((self.scrollView.frame.size.height - scaleInWidth*[[TopPlacesModelLayer sharedModelLayer] downloadedPhoto].size.height)*0.5);
                }
                else {
                    scaleInHeight = scaleInHeight > 10.0 ? 10.0:scaleInHeight;
                    offsetX = ABS((self.scrollView.frame.size.width - scaleInHeight*[[TopPlacesModelLayer sharedModelLayer] downloadedPhoto].size.width)*0.5);
                    offsetY = 0.0;
                }
                self.imageView.frame = CGRectMake(offsetX, offsetY, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
                [self.imageView setImage:[[TopPlacesModelLayer sharedModelLayer] downloadedPhoto]];
                //Add imageView as subview of the scrollView
                [self.scrollView addSubview:self.imageView];
                //Set the zoom scale of the scrollView
                [self.scrollView setZoomScale:MIN(scaleInWidth, scaleInHeight)];
                //Hidden the navigation bar
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (MIN(self.scrollView.contentSize.width/[UIScreen mainScreen].bounds.size.width, self.scrollView.contentSize.height/[UIScreen mainScreen].bounds.size.height) < 1) {
        [self.imageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height*0.5)];
    }
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
