//
//  TopPlacesTableViewController.m
//  Top Places
//
//  Created by Nirvana on 14-1-20.
//  Copyright (c) 2014年 Nirvana.icy. All rights reserved.
//

#import "FlickrFetcher.h"
#import "TopPlacesTableViewController.h"
#import "TopPlacesPhotoListTableViewController.h"

static void *kCountryIndexDictKVOKey = &kCountryIndexDictKVOKey;

@interface TopPlacesTableViewController ()

@end

@implementation TopPlacesTableViewController

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
    [[TopPlacesModelLayer sharedModelLayer] addObserver:self forKeyPath:@"countryIndexDict" options:NSKeyValueObservingOptionNew context:kCountryIndexDictKVOKey];
    [[TopPlacesModelLayer sharedModelLayer] queryTopPlacesInFlickr];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (kCountryIndexDictKVOKey == context) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.tableView reloadData]; 
        });
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
    if ([TopPlacesModelLayer sharedModelLayer].countryIndexDict)
        return [[[TopPlacesModelLayer sharedModelLayer].countryIndexDict allKeys] count];
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([TopPlacesModelLayer sharedModelLayer].countryIndexDict)
        return [[[TopPlacesModelLayer sharedModelLayer].countryIndexDict valueForKey:[[[TopPlacesModelLayer sharedModelLayer].countryIndexDict allKeys] objectAtIndex:section]] count];
    else
        return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([TopPlacesModelLayer sharedModelLayer].countryIndexDict)
        return [[[TopPlacesModelLayer sharedModelLayer].countryIndexDict allKeys] objectAtIndex:section];
    else
        return @"Loading...";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopPlacesTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    if ([TopPlacesModelLayer sharedModelLayer].countryIndexDict) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        NSString * sectionName = [[[TopPlacesModelLayer sharedModelLayer].countryIndexDict allKeys] objectAtIndex:[indexPath section]];
        NSString *placeArrayIndex = [[[TopPlacesModelLayer sharedModelLayer].countryIndexDict valueForKey:sectionName] objectAtIndex:[indexPath row]];
        NSString * placeContentString = [[[[TopPlacesModelLayer sharedModelLayer].responseTopPlacesDict valueForKeyPath:FLICKR_RESULTS_PLACES] objectAtIndex:[placeArrayIndex intValue]] valueForKeyPath:FLICKR_PLACE_NAME];
        NSArray *placeContentStringItems = [placeContentString componentsSeparatedByString:@", "];
        cell.textLabel.text = [placeContentStringItems firstObject];
        if (3 == [placeContentStringItems count]) {
            cell.detailTextLabel.text = placeContentStringItems[1];
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
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:self.selectIndex];
    [segue.destinationViewController setCityName:cell.textLabel.text];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndex = indexPath;
    [self performSegueWithIdentifier:@"SeguePushToPhotoGrid" sender:self];
}

@end
