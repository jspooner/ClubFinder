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

@interface BeaconManager : NSObject <FYXVisitDelegate, FYXServiceDelegate>
@property (strong, nonatomic) FYXVisitManager *visitManager;
@property (nonatomic) NSMutableArray *transmitters;
@property (nonatomic) NSMutableArray *mySavedTransmitters;
-(id)init;
@end
