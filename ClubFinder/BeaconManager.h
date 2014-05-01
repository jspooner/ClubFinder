//
//  BeaconManager.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/25/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FYX/FYX.h>
#import <FYX/FYXVisitManager.h>
#import <ContextLocation/QLContextPlaceConnector.h>
#import "Transmitter.h"
#import "LocationTracker.h"

@interface BeaconManager : NSObject <FYXVisitDelegate, FYXServiceDelegate>

@property (nonatomic) LocationTracker *locationTracker;
@property (strong, nonatomic) FYXVisitManager *visitManager;
@property (atomic) NSMutableArray *transmitters;
@property (atomic) NSMutableArray *mySavedTransmitters;

-(id)initWith:(LocationTracker *)locationTracker;
- (Transmitter *)transmitterForID:(NSString *)ID;

@end
