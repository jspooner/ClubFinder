//
//  LocationLogger.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 3/28/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "LocationTracker.h"
#import "CFLogger.h"

@implementation LocationTracker {
    CLLocationManager *_locationManager;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self startTracking];
    }
    
    return self;
}

-(void)startTracking
{
    DDLogCVerbose(@"LocationLogger startTracking");
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 1;
    _locationManager.activityType = CLActivityTypeFitness;
//    [_locationManager startUpdatingLocation];
//    [_locationManager startUpdatingHeading];
    [_locationManager startMonitoringSignificantLocationChanges];
}

#pragma - mark
#pragma - mark CLLocation Manager Delegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSArray *params = @[
                        @"e=/location/didFailWithError",
                        [@[@"error", error] componentsJoinedByString:@"="]
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations objectAtIndex:0];
    NSArray *params = @[
                        @"e=/location/didUpdateLocations",
                        [@[@"timestamp", location.timestamp] componentsJoinedByString:@"="],
                        [@[@"speed", [NSString stringWithFormat:@"%f", location.speed]] componentsJoinedByString:@"="],
                        [@[@"course", [NSString stringWithFormat:@"%f", location.course]] componentsJoinedByString:@"="],
                        [@[@"horizontalAccuracy", [NSString stringWithFormat:@"%f", location.horizontalAccuracy]] componentsJoinedByString:@"="],
                        [@[@"verticalAccuracy", [NSString stringWithFormat:@"%f", location.verticalAccuracy]] componentsJoinedByString:@"="],
                        [@[@"latitude", [NSString stringWithFormat:@"%f", location.coordinate.latitude]] componentsJoinedByString:@"="],
                        [@[@"longitude", [NSString stringWithFormat:@"%f", location.coordinate.longitude]] componentsJoinedByString:@"="]
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    NSArray *params = @[
                        @"e=/location/didUpdateHeading",
                        [@[@"timestamp", newHeading.timestamp] componentsJoinedByString:@"="],
                        [@[@"magneticHeading", [NSString stringWithFormat:@"%f", newHeading.magneticHeading]] componentsJoinedByString:@"="],
                        [@[@"trueHeading", [NSString stringWithFormat:@"%f", newHeading.trueHeading]] componentsJoinedByString:@"="],
                        [@[@"headingAccuracy", [NSString stringWithFormat:@"%f", newHeading.headingAccuracy]] componentsJoinedByString:@"="],
                        [@[@"x", [NSString stringWithFormat:@"%f", newHeading.x]] componentsJoinedByString:@"="],
                        [@[@"y", [NSString stringWithFormat:@"%f", newHeading.y]] componentsJoinedByString:@"="],
                        [@[@"z", [NSString stringWithFormat:@"%f", newHeading.z]] componentsJoinedByString:@"="]
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
}

@end
