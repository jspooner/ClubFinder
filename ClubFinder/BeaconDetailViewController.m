//
//  BeaconDetailViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/30/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "BeaconDetailViewController.h"
#import "UIViewController+TransmitterViewHelper.h"

@interface BeaconDetailViewController (TransmitterViewHelper)

@end

@implementation BeaconDetailViewController

-(id)initWithBeacon:(BeaconManager *)manager andTransmitter:(NSString *)identifer
{
    self = [super initWithNibName:@"BeaconDetailViewController" bundle:nil];
    if (self) {
        self.beaconManager = manager;
        self.transmitter = [self transmitterForID:identifer];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.transmitter == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"I couldn't find that beacon" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
    }
    self.title = [NSString stringWithFormat:@"Beacon %@", self.transmitter.name];
    [self updateTransmitterView];
    [self updateRssiView];
    [self startObserving];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [self stopObserving];
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
#pragma mark - Observer Handelers

-(void)transmitterAdded{}

-(void)transmitterUpdated:(NSNotification *)notification
{
    Transmitter *transmitter = [self transmitterForID:[[notification userInfo] objectForKey:@"identifier"]];
    if ([transmitter.identifier isEqualToString:self.transmitter.identifier]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateTransmitterView];
        });
    }
}

-(void)transmitterDidDepart:(NSNotification *)notification
{
    Transmitter *transmitter = [self transmitterForID:[[notification userInfo] objectForKey:@"identifier"]];
    if ([transmitter.identifier isEqualToString:self.transmitter.identifier]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }
}

#pragma mark - 
#pragma mark - Helpers

-(void)updateTransmitterView
{
    // Label
    self.nameLabel.text = self.transmitter.name;
    [self updateRssiView];
    // Battery
    UIImage *batteryImage = [self getBatteryImageForLevel:self.transmitter.batteryLevel];
    [self.batteryImageView setImage:batteryImage];
    self.temperature.text = [NSString stringWithFormat:@"%@%@", self.transmitter.temperature,
                             [NSString stringWithUTF8String:"\xC2\xB0 F" ]];
}

-(void)updateRssiView
{
    // Bar
    float oldBarWidth = [self barWidthForRSSI:self.transmitter.previousRSSI];
    float newBarWidth = [self barWidthForRSSI:self.transmitter.rssi];
    CGRect tempFrame = self.rssiImageView.frame;
    CGRect oldFrame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, oldBarWidth, tempFrame.size.height);
    CGRect newFrame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, newBarWidth, tempFrame.size.height);
    // Animate updating the RSSI indicator bar
    self.rssiImageView.frame = oldFrame;
    [UIView animateWithDuration:1.0f animations:^{
        self.rssiImageView.frame = newFrame;
    }];
    self.rssiLabel.text = [NSString stringWithFormat:@"%@", self.transmitter.rssi];
}

/**
 *
 * TODO Move to BeconManager
 *
 **/
- (Transmitter *)transmitterForID:(NSString *)ID {
    for (Transmitter *transmitter in self.beaconManager.transmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    for (Transmitter *transmitter in self.beaconManager.mySavedTransmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    return nil;
}


@end
