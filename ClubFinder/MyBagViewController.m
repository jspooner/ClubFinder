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
#import "BeaconViewController.h"
#import "BeaconDetailViewController.h"

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
    self.tableView.backgroundColor = [[UIColor alloc] initWithWhite:1 alpha:0.0];
    [self configureNavController];
    [self setBackgroundEffect];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self stopObserving];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self startObserving];
    [self.tableView reloadData];
}

-(void)configureNavController
{
    self.title = @"My Clubs";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addBeacon)];
}

-(void)startObserving
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transmitterUpdated:)
                                                 name:@"transmitterUpdated"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transmitterDidDepart:)
                                                 name:@"transmitterDidDepart"
                                               object:nil];
}

-(void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"transmitterUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"transmitterDidDepart" object:nil];
}

#pragma mark -
#pragma mark - NavigationController button handlers

-(void)editBag{}

-(void)addBeacon
{
    BeaconViewController *bvc = [[BeaconViewController alloc] initWithBeacon:self.beaconManager];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bvc] animated:YES completion:nil];
}


#pragma mark -
#pragma mark - Observer Handelers

-(void)transmitterAdded
{
    [self.tableView reloadData];
}

-(void)transmitterUpdated:(NSNotification *)notification
{
    Transmitter *transmitter = [self transmitterForID:[[notification userInfo] objectForKey:@"identifier"]];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        SightingsTableViewCell *sightingsCell = (SightingsTableViewCell*)cell;
        if ([sightingsCell.transmitterIdentifier isEqualToString:transmitter.identifier]) {
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
        SightingsTableViewCell *sightingsCell = (SightingsTableViewCell *)cell;
        if ([sightingsCell.transmitterIdentifier isEqualToString:transmitter.identifier]) {
            [self grayOutSightingsCell:((SightingsTableViewCell*)cell)];
        }
    }
}

#pragma mark -
#pragma mark - Helpers

- (Transmitter *)transmitterForID:(NSString *)ID {
    for (Transmitter *transmitter in self.beaconManager.mySavedTransmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    return nil;
}

-(void)setBackgroundEffect
{
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [self.backgroundImage addMotionEffect:group];
}

#pragma mark -
#pragma mark - ViewHelpers

- (BOOL)isTransmitterAgedOut:(Transmitter *)transmitter {
    NSDate *now = [NSDate date];
    NSTimeInterval ageOutPeriod = 15; //[[NSUserDefaults standardUserDefaults] integerForKey:@"age_out_period"];
    if ([now timeIntervalSinceDate:transmitter.lastSighted] > ageOutPeriod) {
        return YES;
    }
    return NO;
}

- (void)grayOutSightingsCell:(SightingsTableViewCell *)sightingsCell
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
    NSLog(@"179");
    return [self.beaconManager.mySavedTransmitters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyReusableCell";
    SightingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Transmitter *transmitter = [self.beaconManager.mySavedTransmitters objectAtIndex:indexPath.row];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SightingsTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.transmitterIcon.image = [UIImage imageNamed:@"Avatar"];
    cell.transmitterNameLabel.text = transmitter.name;
    cell.transmitterIdentifier = transmitter.identifier;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SightingsTableViewCell *cell = (SightingsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    BeaconDetailViewController *detailVC = [[BeaconDetailViewController alloc] initWithBeacon:self.beaconManager andTransmitter:cell.transmitterIdentifier];
    [[self navigationController] pushViewController:detailVC animated:YES];
}

@end
