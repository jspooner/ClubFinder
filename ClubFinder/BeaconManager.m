//
//  BeaconManager.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/25/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "BeaconManager.h"
#import "CFLogger.h"
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXTransmitter.h>
#import <FYX/FYXSightingManager.h>
#import <FYX/FYXLogging.h>
#import <ContextLocation/QLContextPlaceConnector.h>
#import "Transmitter.h"

@implementation BeaconManager

#if DEBUG
#define VISIT_DURATION_INTERVAL_IN_SECONDS 5
#else
#define VISIT_DURATION_INTERVAL_IN_SECONDS 15
#endif

-(id)initWith:(LocationTracker *)locationTracker;
{
    if ( self = [super init] ) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"mySavedTransmitters"];
        self.locationTracker = locationTracker;
        self.transmitters = [NSMutableArray new];
        self.transmitters = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        [self initBeacon];
        [self initObservers];
    }
    return self;
}

-(void)initBeacon
{
    [[CFLogger sharedInstance] logEvent:@"initBeacon"];
    [FYXLogging setLogLevel:FYX_LOG_LEVEL_VERBOSE];
    [FYX setAppId:@"ff0cc75b23cc0b03cb266cf617908c0aed6f03bd549dd7d6bc58da64b4d0fb90"
        appSecret:@"2acc48534c2c20ad470cc3ec5c947e51d71126bafc39c2b1075675dd72a235fa"
      callbackUrl:@"clubfinder://authcode"];
    [FYX startService:self];
}

-(void)initObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transmitterAdded:)
                                                 name:@"transmitterAdded"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transmitterRemoved:)
                                                 name:@"transmitterRemoved"
                                               object:nil];

}

#pragma - mark
#pragma - mark Observers

-(void)transmitterAdded:(NSNotification *)notification
{
    Transmitter *temp = [self transmitterForID:[[notification userInfo] objectForKey:@"transmitterIdentifier"]];
    if (temp) {
        [temp setInBag:YES];
        [self saveTransmittersToNSUserDefaults];
    }
}

-(void)transmitterRemoved:(NSNotification *)notification
{
    Transmitter *temp = [self transmitterForID:[[notification userInfo] objectForKey:@"transmitterIdentifier"]];
    if (temp) {
        [temp setInBag:NO];
        [self saveTransmittersToNSUserDefaults];
    }
}

#pragma - mark
#pragma - mark FYX

- (void)serviceStarted
{
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    [[CFLogger sharedInstance] logEvent:@"e=app/gimbal/serviceStarted"];
    self.visitManager = [[FYXVisitManager alloc] init];
    self.visitManager.delegate = self;
    NSMutableDictionary *options = [NSMutableDictionary new];
    
    /*
     Number of seconds before the absence of a beacon triggers the didDepart callback
     */
    [options setObject:[NSNumber numberWithInt:VISIT_DURATION_INTERVAL_IN_SECONDS] forKey:FYXVisitOptionDepartureIntervalInSecondsKey];
    
    /*
     Signal Strength Window
     Smoothing of signal strengths using historic sliding window averaging
     
     This option allows for a window of historic signal strengths to be used for a given device to "smooth" them out to remove quick jumps in signal strength. The larger the window the less the signal strength will jump but the slower it will react to the signal strength changes.
     
     FYXSightingOptionSignalStrengthWindowKey	FYXSightingOptionSignalStrengthWindowNone	No window of historic signal strengths is used
     FYXSightingOptionSignalStrengthWindowKey	FYXSightingOptionSignalStrengthWindowSmall	A small window of historic signal strengths is used
     FYXSightingOptionSignalStrengthWindowKey	FYXSightingOptionSignalStrengthWindowMedium	A medium window of historic signal strengths is used
     FYXSightingOptionSignalStrengthWindowKey	FYXSightingOptionSignalStrengthWindowLarge	A large window of historic signal strengths is used
     
     */
    [options setObject:[NSNumber numberWithInt:FYXSightingOptionSignalStrengthWindowLarge] forKey:FYXSightingOptionSignalStrengthWindowKey];
    
    /*
     An RSSI value of the beacon sighting that must be exceeded before a didArrive callback is triggered
     [options setObject:-75 forKey:FYXVisitOptionArrivalRSSIKey];
     */
    
    /*
     If an RSSI value of the beacon sightings is less than this value and the departure interval is exceeded a didDepart callback is triggered
     [options setObject:[NSNumber numberWithInt:-90] forKey:FYXVisitOptionDepartureRSSIKey];
     */
    [self.visitManager startWithOptions:options];

}

- (void)startServiceFailed:(NSError *)error
{
    // this will be called if the service has failed to start
    [[CFLogger sharedInstance] logEvent: [NSString stringWithFormat:@"e=app/gimbal/startServiceFailed&error=%@", error]];
}


#pragma - mark
#pragma - mark FYXVisitDelegate

- (void)didArrive:(FYXVisit *)visit
{
    // this will be invoked when an authorized transmitter is sighted for the first time
    NSArray *params = @[
                        @"e=/beacon/didArrive",
                        [@[@"identifer", visit.transmitter.identifier] componentsJoinedByString:@"="],
                        [@[@"name", visit.transmitter.name] componentsJoinedByString:@"="],
                        [@[@"ownerId", visit.transmitter.ownerId] componentsJoinedByString:@"="],
                        [@[@"battery", visit.transmitter.battery] componentsJoinedByString:@"="],
                        [@[@"temperature", visit.transmitter.temperature] componentsJoinedByString:@"="]
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
    NSDictionary *dictionary = @{
                                 @"identifier" : visit.transmitter.identifier,
                                 @"name" : visit.transmitter.name
                                 };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterDidArrive" object:self userInfo:dictionary];
}

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSArray *params = @[
                        @"e=/beacon/receivedSighting",
                        [@[@"identifer", visit.transmitter.identifier] componentsJoinedByString:@"="],
                        [@[@"name", visit.transmitter.name] componentsJoinedByString:@"="],
                        [@[@"ownerId", visit.transmitter.ownerId] componentsJoinedByString:@"="],
                        [@[@"battery", visit.transmitter.battery] componentsJoinedByString:@"="],
                        [@[@"temperature", visit.transmitter.temperature] componentsJoinedByString:@"="],
                        [@[@"updateTime", updateTime] componentsJoinedByString:@"="],
                        [@[@"rssi", RSSI] componentsJoinedByString:@"="],
                        [@[@"latitude", [NSString stringWithFormat:@"%f", self.locationTracker.lastLocation.coordinate.latitude]] componentsJoinedByString:@"="],
                        [@[@"longitude", [NSString stringWithFormat:@"%f", self.locationTracker.lastLocation.coordinate.longitude]] componentsJoinedByString:@"="]
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];

    Transmitter *transmitter = [self transmitterForID:visit.transmitter.identifier];
    if (!transmitter) {
        NSString *transmitterName = visit.transmitter.identifier;
        if(visit.transmitter.name){
            transmitterName = visit.transmitter.name;
        }
        transmitter = [Transmitter new];
        transmitter.identifier = visit.transmitter.identifier;
        transmitter.name = transmitterName;
        transmitter.lastSighted = [NSDate dateWithTimeIntervalSince1970:0];
        transmitter.rssi = [NSNumber numberWithInt:-100];
        transmitter.previousRSSI = transmitter.rssi;
        transmitter.batteryLevel = 0;
        transmitter.temperature = 0;
        [self.transmitters addObject:transmitter];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterAdded" object:self userInfo:nil];
    }
    if (self.locationTracker.lastLocation != nil) {
        float smalerRSSI = [RSSI floatValue] * -1;
        if (smalerRSSI > 70) {
            transmitter.lastLocation = self.locationTracker.lastLocation;
            transmitter.lastLocationTimestamp = self.locationTracker.lastLocationTimestamp;
        }
    }
    transmitter.lastSighted = updateTime;
    
    if([self shouldUpdateTransmitterCell:visit withTransmitter:transmitter RSSI:RSSI]){
        [self updateTransmitter:transmitter withVisit:visit RSSI:RSSI];
        NSDictionary *dictionary = @{@"identifier" : transmitter.identifier};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterUpdated" object:self userInfo:dictionary];
    }
}

- (void)didDepart:(FYXVisit *)visit
{
    // this will be invoked when an authorized transmitter has not been sighted for some time
    // LOGGING
    NSArray *params = @[
                        @"e=/beacon/didDepart",
                        [@[@"identifer", visit.transmitter.identifier] componentsJoinedByString:@"="],
                        [@[@"name", visit.transmitter.name] componentsJoinedByString:@"="],
                        [@[@"ownerId", visit.transmitter.ownerId] componentsJoinedByString:@"="],
                        [@[@"battery", visit.transmitter.battery] componentsJoinedByString:@"="],
                        [@[@"temperature", visit.transmitter.temperature] componentsJoinedByString:@"="],
                        [@[@"dwellTime", [NSString stringWithFormat:@"%f", visit.dwellTime]] componentsJoinedByString:@"="]
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
    NSDictionary *dictionary = @{
                                 @"identifier" : visit.transmitter.identifier,
                                 @"lastUpdateTime" : visit.lastUpdateTime,
                                 @"startTime" : visit.startTime,
                                 @"dwellTime" : [NSNumber numberWithDouble:visit.dwellTime]
                                 };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterDidDepart" object:self userInfo:dictionary];
//    // START ALERT OF NOTIFICATION
//    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
//    if (state == UIApplicationStateActive)
//    {
//        [[CFLogger sharedInstance] logEvent:@"e=/beacon/didDepart&state=UIApplicationStateActive"];
//    }
//    else if (state == UIApplicationStateBackground)
//    {
//        [[CFLogger sharedInstance] logEvent:@"e=/beacon/didDepart&state=UIApplicationStateBackground"];
//    }
//    else if (state == UIApplicationStateInactive)
//    {
//        [[CFLogger sharedInstance] logEvent:@"e=/beacon/didDepart&state=UIApplicationStateInactive"];
//    }
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
//        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
//            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//            [dateFormat setDateFormat:@"yyyy-MM-dd"];
//            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
//            [timeFormat setDateFormat:@"HH:mm:ss"];
//            NSDate *now =  [NSDate dateWithTimeIntervalSinceNow:1];
//            NSString *theDate = [dateFormat stringFromDate:now];
//            NSString *theTime = [timeFormat stringFromDate:now];
//            NSLog(@"\n"
//                  "theDate: |%@| \n"
//                  "theTime: |%@| \n"
//                  , theDate, theTime);
//            UILocalNotification *myNote = [[UILocalNotification alloc] init];
//            myNote.fireDate =  now;
//            myNote.timeZone = [NSTimeZone defaultTimeZone];
//            myNote.alertBody = [NSString stringWithFormat:@"Did you lose %@ at %@?", visit.transmitter.name, theTime];
//            myNote.alertAction = @"View Details";
//            myNote.soundName = UILocalNotificationDefaultSoundName;
//            [[UIApplication sharedApplication] scheduleLocalNotification:myNote];
//            [[CFLogger sharedInstance] logEvent:[@[
//                                                   @"e=/alert/localnotification",
//                                                   [@[@"date", theDate] componentsJoinedByString:@"="],
//                                                   [@[@"time", theTime] componentsJoinedByString:@"="],
//                                                   ] componentsJoinedByString:@"&"]];
//        } else {
//            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"I left the proximity of a Gimbal Beacon!!!! %@", visit.transmitter.name]
//                                        message:[NSString stringWithFormat:@"I was around the beacon for %f seconds", visit.dwellTime]
//                                       delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] show];
//            [[CFLogger sharedInstance] logEvent:[@[
//                                                   @"e=/alert/uialertview",
//                                                   ] componentsJoinedByString:@"&"]];
//
//        }
//    }];
}

#pragma mark -
#pragma mark - Public

/**
 *
 *  This public method shoud look at both arrays... maybe
 *
 **/
- (Transmitter *)transmitterForID:(NSString *)ID {
    for (Transmitter *transmitter in self.transmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    return nil;
}

-(NSArray*)transmittersInBag
{
    NSIndexSet* indexes = [_transmitters indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Transmitter * t = (Transmitter*)obj;
        return t.inBag;
    }];
    NSArray* newArray = [_transmitters objectsAtIndexes:indexes];
    
    return newArray;
}

#pragma mark -
#pragma mark - Helpers

-(void)saveTransmittersToNSUserDefaults
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.transmitters];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"mySavedTransmitters"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldUpdateTransmitterCell:(FYXVisit *)visit withTransmitter:(Transmitter *)transmitter RSSI:(NSNumber *)rssi
{
    if (![transmitter.rssi isEqual:rssi] || ![transmitter.batteryLevel isEqualToNumber:visit.transmitter.battery]
        || ![transmitter.temperature isEqualToNumber:visit.transmitter.temperature]){
        return YES;
    }
    else {
        return NO;
    }
}

- (void)updateTransmitter:(Transmitter *)transmitter withVisit:(FYXVisit *)visit RSSI:(NSNumber *)rssi
{
    transmitter.previousRSSI = transmitter.rssi;
    transmitter.rssi = rssi;
    transmitter.batteryLevel = visit.transmitter.battery;
    transmitter.temperature = visit.transmitter.temperature;
}



@end
