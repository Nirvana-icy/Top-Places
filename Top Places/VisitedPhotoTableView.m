//
//  ViewedPhotoTableView.m
//  Top Places
//
//  Created by Nirvana on 14-2-3.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import "VisitedPhotoTableView.h"
#import "TopPlacesModelLayer.h"
#import "FlickrFetcher.h"

@interface VisitedPhotoTableView ()
@property (nonatomic, strong) NSUserDefaults *appDefault;

@end

@implementation VisitedPhotoTableView

- (NSUserDefaults *)appDefault
{
    if (nil == _appDefault) {
        _appDefault = [NSUserDefaults standardUserDefaults];
        if (nil == [_appDefault objectForKey:@"viewedPhotoArray"]) {   //if we never visit appDefault before => set default value
            [_appDefault setInteger:-1 forKey:@"index"];
            [_appDefault setObject:[NSMutableArray arrayWithCapacity:20] forKey:@"viewedPhotoArray"];
        }
    }
    return _appDefault;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[self.appDefault arrayForKey:@"viewedPhotoArray"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VistedPhoto";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if ([[TopPlacesModelLayer sharedModelLayer] viewedPhotoArray]) {
        NSDictionary *photoDict = [[[TopPlacesModelLayer sharedModelLayer] viewedPhotoArray] objectAtIndex:[indexPath row]];
        NSString *photoTitle = [photoDict valueForKeyPath:FLICKR_PHOTO_TITLE];
        NSString *photoDescription = [photoDict valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        
        NSString *tempLabelText = [photoTitle length] > 0 ? photoTitle : photoDescription;
        cell.textLabel.text = [tempLabelText length] > 0 ? tempLabelText : @"Unknow";
    }
    else
        cell.textLabel.text = @"No available.";
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *appDefault = [NSUserDefaults standardUserDefaults];
    NSInteger firstCellObjectIndexInArray = [appDefault integerForKey:@"index"];
    NSInteger selectedCellObjectIndexInArray = firstCellObjectIndexInArray - [indexPath row];
    if (selectedCellObjectIndexInArray < 0) selectedCellObjectIndexInArray += 20;
    NSDictionary *selectPhotoDict = [NSDictionary dictionaryWithDictionary:[[appDefault objectForKey:@"viewedPhotoArray"] objectAtIndex:selectedCellObjectIndexInArray]];
    //Retrieve the URL of the selected Photo
    self.selectPhotoURL = [FlickrFetcher URLforPhoto:selectPhotoDict  format:FlickrPhotoFormatOriginal];
    UITableViewCell *selectedCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    self.selectedPhotoDescription = selectedCell.textLabel.text;
    [self performSegueWithIdentifier:@"SeguePushToVistedPhotoDetail" sender:self];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.tabBarController.tabBar.hidden = YES;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [segue.destinationViewController setSelectPhotoURL:self.selectPhotoURL];
    [segue.destinationViewController setSelectedPhotoDescription:self.selectedPhotoDescription];
}

@end
