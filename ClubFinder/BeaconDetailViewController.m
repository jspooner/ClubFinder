//
//  BeaconDetailViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/30/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "BeaconDetailViewController.h"
#import "UIViewController+TransmitterViewHelper.h"
#import <GoogleMaps/GoogleMaps.h>

@interface BeaconDetailViewController (TransmitterViewHelper)
@end

@implementation BeaconDetailViewController {
    GMSMapView *_mapView;
    GMSMarker *_beaconMarker;
}

-(id)initWithBeacon:(BeaconManager *)manager andTransmitter:(NSString *)identifer
{
    self = [super initWithNibName:@"BeaconDetailViewController" bundle:nil];
    if (self) {
        self.beaconManager = manager;
        self.transmitter = [self.beaconManager transmitterForID:identifer];
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
    [self initMap];
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
    Transmitter *transmitter = [self.beaconManager transmitterForID:[[notification userInfo] objectForKey:@"identifier"]];
    if ([transmitter.identifier isEqualToString:self.transmitter.identifier]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateTransmitterView];
        });
    }
}

-(void)transmitterDidDepart:(NSNotification *)notification
{
    Transmitter *transmitter = [self.beaconManager transmitterForID:[[notification userInfo] objectForKey:@"identifier"]];
    if ([transmitter.identifier isEqualToString:self.transmitter.identifier]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }
}

#pragma mark - 
#pragma mark - Helpers

-(void)initMap
{
    GMSCameraPosition *camera = nil;
    if (self.transmitter.lastLocation != nil) {
        camera = [GMSCameraPosition cameraWithLatitude:self.transmitter.lastLocation.coordinate.latitude
                                             longitude:self.transmitter.lastLocation.coordinate.longitude
                                                  zoom:20];
        _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 210, self.view.frame.size.width, self.view.frame.size.height-210) camera:camera];
        _mapView.myLocationEnabled = YES;
        [self addBeaconToMap];
        [self.view addSubview:_mapView];
    }
}

-(void)addBeaconToMap
{
    if (self.transmitter.lastLocation != nil) {
        
        if (_beaconMarker) {
            _beaconMarker.map = nil;
            [_mapView clear];
        }
        _beaconMarker = [[GMSMarker alloc] init];
        _beaconMarker.position = CLLocationCoordinate2DMake(self.transmitter.lastLocation.coordinate.latitude, self.transmitter.lastLocation.coordinate.longitude);
        _beaconMarker.snippet = [[self getDateFormat] stringFromDate:self.transmitter.lastLocationTimestamp];
        _beaconMarker.map = _mapView;
        CLLocationCoordinate2D circleCenter = self.transmitter.lastLocation.coordinate;
        float circleRadius = [self.transmitter.rssi floatValue] * -1 / 8;
        GMSCircle *circ = [GMSCircle circleWithPosition:circleCenter radius:circleRadius];
        circ.fillColor = [UIColor colorWithRed:0.50 green:0 blue:0 alpha:0.05];
        circ.strokeColor = [UIColor redColor];
        circ.strokeWidth = 1;
        circ.map = _mapView;
    }
}

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
    self.lastLocation.text = [NSString stringWithFormat:@"Beacon location %.6f, %.6f", self.transmitter.lastLocation.coordinate.latitude, self.transmitter.lastLocation.coordinate.longitude];
    self.lastLocationTimestamp.text = [[self getDateFormat] stringFromDate:self.transmitter.lastLocationTimestamp];
    [self addBeaconToMap];
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

-(NSDateFormatter*)getDateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    return formatter;
}

@end
