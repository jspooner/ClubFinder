//
//  BeaconViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/25/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "BeaconViewController.h"
#import "FindTableViewCell.h"
#import "Transmitter.h"
#import "UIViewController+TransmitterViewHelper.h"

@interface BeaconViewController (TransmitterViewHelper)

@end

@implementation BeaconViewController

-(id)initWithBeacon:(BeaconManager *)manager
{
    self = [super initWithNibName:@"BeaconViewController" bundle:nil];
    if (self) {
        self.beaconManager = manager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.beaconManager) {
        NSLog(@"I have a beacon manager");
        // You still need to remove listeners before they are deleted.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transmitterDidArrive:)
                                                     name:@"transmitterDidArrive"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transmitterAdded)
                                                     name:@"transmitterAdded"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transmitterUpdated:)
                                                     name:@"transmitterUpdated"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transmitterDidDepart:)
                                                     name:@"transmitterDidDepart"
                                                   object:nil];
    }
    self.title = @"Add Clubs";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(donePressed)];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"transmitterAdded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"transmitterDidArrive" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"transmitterUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"transmitterDidDepart" object:nil];
}

#pragma mark -
#pragma mark - NavigationController button handlers

-(void)donePressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Observer Handelers

-(void)transmitterAdded
{
    [self.tableView reloadData];
}

-(void)transmitterDidArrive:(NSNotification *)notification
{
    [self.tableView reloadData];
}

-(void)transmitterUpdated:(NSNotification *)notification
{
    NSNumber *index = [[notification userInfo] objectForKey:@"index"];
    int i = [index intValue];
    Transmitter *transmitter = [self.beaconManager.transmitters objectAtIndex:[index intValue]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([[self.tableView indexPathForCell:cell] isEqual:indexPath]) {
            FindTableViewCell *sightingsCell = (FindTableViewCell *)cell;

            CALayer *tempLayer = [sightingsCell.rssiImageView.layer presentationLayer];
            transmitter.previousRSSI =  [self rssiForBarWidth:[tempLayer frame].size.width];

            [self updateSightingsCell:sightingsCell withTransmitter:transmitter];
        }
    }

}

-(void)transmitterDidDepart:(NSNotification *)notification
{
    Transmitter *transmitter = [self transmitterForID:[[notification userInfo] objectForKey:@"identifier"]];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        FindTableViewCell *sightingsCell = (FindTableViewCell *)cell;
        if ([sightingsCell.transmitterIdentifier isEqualToString:transmitter.identifier]) {
            [self grayOutSightingsCell:((FindTableViewCell*)cell)];
        }
    }
}

#pragma mark -
#pragma mark - Helpers

- (Transmitter *)transmitterForID:(NSString *)ID {
    for (Transmitter *transmitter in self.beaconManager.transmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark - ViewHelpers

- (void)grayOutSightingsCell:(FindTableViewCell *)sightingsCell
{
    if (sightingsCell) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sightingsCell.contentView.alpha = 0.3f;
            CGRect oldFrame = sightingsCell.rssiImageView.frame;
            sightingsCell.rssiImageView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, 0, oldFrame.size.height);
            sightingsCell.isGrayedOut = YES;
        });
    }
}

- (void)updateSightingsCell:(FindTableViewCell *)sightingsCell withTransmitter:(Transmitter *)transmitter
{
    if (sightingsCell && transmitter) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sightingsCell.contentView.alpha = 1.0f;
            
            float oldBarWidth = [self barWidthForRSSI:transmitter.previousRSSI];
            float newBarWidth = [self barWidthForRSSI:transmitter.rssi];
            CGRect tempFrame = sightingsCell.rssiImageView.frame;
            CGRect oldFrame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, oldBarWidth, tempFrame.size.height);
            CGRect newFrame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, newBarWidth, tempFrame.size.height);
            
            // Animate updating the RSSI indicator bar
            sightingsCell.rssiImageView.frame = oldFrame;
            [UIView animateWithDuration:1.0f animations:^{
                sightingsCell.rssiImageView.frame = newFrame;
            }];
            sightingsCell.isGrayedOut = NO;
            UIImage *batteryImage = [self getBatteryImageForLevel:transmitter.batteryLevel];
            [sightingsCell.batteryImageView setImage:batteryImage];
            sightingsCell.temperature.text = [NSString stringWithFormat:@"%@%@", transmitter.temperature,
                                              [NSString stringWithUTF8String:"\xC2\xB0 F" ]];
            sightingsCell.rssiLabel.text = [NSString stringWithFormat:@"%@", transmitter.rssi];
            
        });
    }
}

//-(void)transmitterUpdated:(NSNotification *)notification
//{
//    NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++  transmitterAdded %lu", [notification userInfo]);
//}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconManager.transmitters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"findTableViewCell";
    FindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Transmitter *transmitter = [self.beaconManager.transmitters objectAtIndex:indexPath.row];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FindTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.transmitterIcon.image = [UIImage imageNamed:@"Avatar"];
    cell.transmitterNameLabel.text = transmitter.name;
    cell.transmitterIdentifier = transmitter.identifier;
    if (transmitter.inBag) {
        [cell.bagSwitch setOn:YES];
    }
    if ([self isTransmitterAgedOut:transmitter]) {
        [self grayOutSightingsCell:cell];
    } else {
        [self updateSightingsCell:cell withTransmitter:transmitter];
    }
    
    return cell;
}


#pragma mark -
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

@end
