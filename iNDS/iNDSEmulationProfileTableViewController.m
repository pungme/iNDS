//
//  iNDSEmulationProfileTableViewController.m
//  iNDS
//
//  Created by Will Cobb on 12/23/15.
//  Copyright © 2015 iNDS. All rights reserved.
//

#import "iNDSEmulationProfileTableViewController.h"
#import "iNDSEmulationProfile.h"
#import "AppDelegate.h"
@interface iNDSEmulationProfileTableViewController () {
    NSArray * profiles;
}

@end

@implementation iNDSEmulationProfileTableViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    //[self tableView:self.tableView numberOfRowsInSection:0]
    profiles = [iNDSEmulationProfile profilesAtPath:AppDelegate.sharedInstance.batteryDir];
    UIBarButtonItem * xButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:AppDelegate.sharedInstance.currentEmulatorViewController action:@selector(toggleSettings:)];
    xButton.imageInsets = UIEdgeInsetsMake(7, 3, 7, 0);
    self.navigationItem.rightBarButtonItem = xButton;
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc] initWithTarget:AppDelegate.sharedInstance.currentEmulatorViewController action:@selector(toggleSettings:)];
    tapRecon.numberOfTapsRequired = 2;
    //[self.navigationController.navigationBar addGestureRecognizer:tapRecon];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Table View

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            iNDSEmulationProfile * profile = profiles[indexPath.row];
            if ([profile deleteProfile]) {
                profiles = [iNDSEmulationProfile profilesAtPath:AppDelegate.sharedInstance.batteryDir];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                if ([profile.name isEqualToString:AppDelegate.sharedInstance.currentEmulatorViewController.profile.name]) { //Just deleted current profile
                    //Load default
                    [AppDelegate.sharedInstance.currentEmulatorViewController loadProfile:[[iNDSEmulationProfile alloc] initWithProfileName:@"iNDSDefaultProfile"]];
                }
            } else {
                NSLog(@"Error! unable to delete save state");
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 1;
    return profiles.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Default";
        if ([AppDelegate.sharedInstance.currentEmulatorViewController.profile.name isEqualToString:@"iNDSDefaultProfile"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1) {
        iNDSEmulationProfile * profile = profiles[indexPath.row];
        cell.textLabel.text = profile.name;
        if ([profile.name isEqualToString:AppDelegate.sharedInstance.currentEmulatorViewController.profile.name]) { //Current profile
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

#pragma mark - Select ROMs

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    iNDSEmulationProfile * profile;
    if (indexPath.section == 0) {
        profile = [[iNDSEmulationProfile alloc] initWithProfileName:@"iNDSDefaultProfile"];
    } else if (indexPath.section == 1) {
        profile = profiles[indexPath.row];
    }
    [AppDelegate.sharedInstance.currentEmulatorViewController loadProfile:profile];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [profile ajustLayout];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
