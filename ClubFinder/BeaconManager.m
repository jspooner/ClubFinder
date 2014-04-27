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

#define VISIT_DURATION_INTERVAL_IN_SECONDS 15

-(id)init
{
    if ( self = [super init] ) {
        self.transmitters = [NSMutableArray new];
        self.mySavedTransmitters = [NSMutableArray new];
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
    NSLog(@" -----------  transmitterAdded %@", [notification userInfo]);
    Transmitter *temp = [self transmitterForID:[[notification userInfo] objectForKey:@"transmitterIdentifier"]];
    if (temp) {
        [temp setInBag:YES];
        if ([self.mySavedTransmitters indexOfObject:temp] != -1) {
            [self.mySavedTransmitters addObject:temp];
        }
    }
}

-(void)transmitterRemoved:(NSNotification *)notification
{
    NSLog(@" -----------  transmitterRemoved %@", [notification userInfo]);
    Transmitter *temp = [self transmitterForID:[[notification userInfo] objectForKey:@"transmitterIdentifier"]];
    if (temp) {
        [temp setInBag:NO];
        [self.mySavedTransmitters removeObject:temp];
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

    transmitter.lastSighted = updateTime;
    if([self shouldUpdateTransmitterCell:visit withTransmitter:transmitter RSSI:RSSI]){
        [self updateTransmitter:transmitter withVisit:visit RSSI:RSSI];
        NSDictionary *dictionary = @{@"index" : [NSNumber numberWithUnsignedInteger:[self.transmitters indexOfObject:transmitter]]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterUpdated" object:self userInfo:dictionary];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterUpdated" object:self userInfo:nil];
//        for (UITableViewCell *cell in self.tableView.visibleCells) {
//            if ([[self.tableView indexPathForCell:cell] isEqual:indexPath]) {
//                SightingsTableViewCell *sightingsCell = (SightingsTableViewCell *)cell;
//
//                CALayer *tempLayer = [sightingsCell.rssiImageView.layer presentationLayer];
//                transmitter.previousRSSI =  [self rssiForBarWidth:[tempLayer frame].size.width];
//
//                [self updateSightingsCell:sightingsCell withTransmitter:transmitter];
//            }
//        }
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
    // MANAGE THE TABLE
//    Transmitter *transmitter = [self transmitterForID:visit.transmitter.identifier];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.transmitters indexOfObject:transmitter] inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    if ([cell isKindOfClass:[SightingsTableViewCell class]]) {
//        [self grayOutSightingsCell:((SightingsTableViewCell*)cell)];
//    }
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
#pragma mark - Helpers

- (Transmitter *)transmitterForID:(NSString *)ID {
    for (Transmitter *transmitter in self.transmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    return nil;
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
