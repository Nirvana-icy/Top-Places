//
//  TopPlacesPhotoListTableViewController.m
//  Top Places
//
//  Created by Nirvana on 14-1-25.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import "TopPlacesPhotoListTableViewController.h"

static void *kPhotosDictArray = &kPhotosDictArray;

@interface TopPlacesPhotoListTableViewController ()

@end

@implementation TopPlacesPhotoListTableViewController

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
    [[TopPlacesModelLayer sharedModelLayer] addObserver:self forKeyPath:@"photosDictArray" options:NSKeyValueObservingOptionNew context:kPhotosDictArray];
    
    self.selectCityDict = [[[TopPlacesModelLayer sharedModelLayer].responseTopPlacesDict valueForKeyPath:FLICKR_RESULTS_PLACES] objectAtIndex:self.placeIndexInPlacesArray];
    int totalPhotos = [[self.selectCityDict objectForKey:@"photo_count"] integerValue];
    [[TopPlacesModelLayer sharedModelLayer] queryPhotosOfSelectCityInFlickr:[self.selectCityDict objectForKey:@"place_id"] maxResults:(totalPhotos > 50 ? 50 : totalPhotos)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[TopPlacesModelLayer sharedModelLayer] removeObserver:self forKeyPath:@"photosDictArray" context:kPhotosDictArray];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (kPhotosDictArray == context) {
        if ([TopPlacesModelLayer sharedModelLayer].photosDictArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.topCityPhotoInfoDictArray = [NSArray arrayWithArray:[TopPlacesModelLayer sharedModelLayer].photosDictArray];
                [self.tableView reloadData];
            });
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *contentItem = [[self.selectCityDict objectForKey:@"_content"] componentsSeparatedByString:@", "];
    return [contentItem firstObject];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    int totalPhotos = [[self.selectCityDict objectForKey:@"photo_count"] integerValue];
    return (totalPhotos > 50 ? 50 : totalPhotos);
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopCityPhotoListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([self.topCityPhotoInfoDictArray count] > 0) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        NSString *photoTitle = [[self.topCityPhotoInfoDictArray objectAtIndex:[indexPath row]] valueForKeyPath:FLICKR_PHOTO_TITLE];
        NSString *photoDescription = [[self.topCityPhotoInfoDictArray objectAtIndex:[indexPath row]] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        NSString *tempLabelText =  [photoTitle length] > 0 ? photoTitle : photoDescription;
        cell.textLabel.text = [tempLabelText length] > 0 ? tempLabelText : @"Unknow";
        if (![cell.textLabel.text isEqualToString:photoDescription] && photoDescription) {
            cell.detailTextLabel.text = photoDescription;
        }
    }
    else {
        if (0 == [indexPath row]) {
            cell.textLabel.text = @"                       Loading...";
        }
    }
    return cell;
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
    [segue.destinationViewController setSelectedPhotoIndex:self.selectedPhotoIndex];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPhotoIndex = [indexPath row];
    [self performSegueWithIdentifier:@"SegueToPhotoDisplayView" sender:self];

}

@end
