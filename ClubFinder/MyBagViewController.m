//
//  MyBagViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/27/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "MyBagViewController.h"
#import "SightingsTableViewCell.h"
#import "Transmitter.h"

@interface MyBagViewController ()

@end

@implementation MyBagViewController

-(id)initWithBeacon:(BeaconManager *)manager
{
    self = [super initWithNibName:@"MyBagViewController" bundle:nil];
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
                                                 selector:@selector(transmitterUpdated:)
                                                     name:@"transmitterUpdated"
                                                   object:nil];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"transmitterUpdated" object:nil];
}

#pragma mark -
#pragma mark - Observer Handelers

-(void)transmitterAdded
{
    [self.tableView reloadData];
}

-(void)transmitterUpdated:(NSNotification *)notification
{
    NSNumber *index = [[notification userInfo] objectForKey:@"index"];
    int i = [index intValue];
    Transmitter *transmitter = [self.beaconManager.mySavedTransmitters objectAtIndex:[index intValue]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([[self.tableView indexPathForCell:cell] isEqual:indexPath]) {
            SightingsTableViewCell *sightingsCell = (SightingsTableViewCell *)cell;
            
            CALayer *tempLayer = [sightingsCell.rssiImageView.layer presentationLayer];
            transmitter.previousRSSI =  [self rssiForBarWidth:[tempLayer frame].size.width];
            
            [self updateSightingsCell:sightingsCell withTransmitter:transmitter];
        }
    }
    
}

#pragma mark -
#pragma mark - Helpers


#pragma mark -
#pragma mark - ViewHelpers

- (NSNumber *)rssiForBarWidth:(float)barWidth
{
    NSInteger barMaxValue = -60; // [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_max_value"];
    NSInteger barMinValue = -90; // [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_min_value"];
    
    NSInteger barRange = barMaxValue - barMinValue;
    float percentage = - ((barWidth / 270.0f) - 1.0f);
    float rssiValue = - ((percentage * (float)barRange) - barMaxValue);
    
    return [NSNumber numberWithFloat:rssiValue];
}

- (float)barWidthForRSSI:(NSNumber *)rssi
{
    NSInteger barMaxValue = -60; //[[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_max_value"];
    NSInteger barMinValue = -90; // [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_min_value"];
    
    float rssiValue = [rssi floatValue];
    float barWidth;
    if (rssiValue >= barMaxValue) {
        barWidth = 270.0f;
    } else if (rssiValue <= barMinValue) {
        barWidth = 5.0f;
    } else {
        NSInteger barRange = barMaxValue - barMinValue;
        float percentage = (barMaxValue - rssiValue) / (float)barRange;
        barWidth = (1.0f - percentage) * 270.0f;
    }
    return barWidth;
}


- (void)updateSightingsCell:(SightingsTableViewCell *)sightingsCell withTransmitter:(Transmitter *)transmitter
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

- (UIImage *)getBatteryImageForLevel: (NSNumber *)batteryLevel
{
    switch([batteryLevel integerValue]){
        case 0:
        case 1:
            return [UIImage imageNamed:@"battery_low.png"];
        case 2:
            return [UIImage imageNamed:@"battery_high.png"];
        case 3:
            return [UIImage imageNamed:@"battery_full.png"];
    }
    return [UIImage imageNamed:@"battery_unknown.png"];
}


//-(void)transmitterUpdated:(NSNotification *)notification
//{
//    NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++  transmitterAdded %lu", [notification userInfo]);
//}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconManager.mySavedTransmitters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"findTableViewCell";
    SightingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Transmitter *transmitter = [self.beaconManager.mySavedTransmitters objectAtIndex:indexPath.row];
    
    if (cell != nil) {
        // Update the transmitter text
        cell.transmitterNameLabel.text = transmitter.name;
        
        // Update the transmitter avatar (icon image)
        //        NSInteger avatarID = [UserSettingsRepository getAvatarIDForTransmitterID:transmitter.identifier];
        //        NSString *imageFilename = [NSString stringWithFormat:@"avatar_%02d.png", avatarID];
        cell.transmitterIcon.image = [UIImage imageNamed:@"Avatar"];
        
        //        if ([self isTransmitterAgedOut:transmitter]) {
        //            [self grayOutSightingsCell:cell];
        //        } else {
        //            [self updateSightingsCell:cell withTransmitter:transmitter];
        //        }
    } else {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FindTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.transmitterIdentifier = transmitter.identifier;
        cell.transmitterNameLabel.text = transmitter.name;
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
