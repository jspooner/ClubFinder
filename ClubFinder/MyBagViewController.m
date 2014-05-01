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
#import "UIViewController+TransmitterViewHelper.h"

@interface MyBagViewController (TransmitterViewHelper)

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
