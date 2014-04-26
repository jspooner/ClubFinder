//
//  BeaconManager.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/25/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FYX/FYXVisitManager.h>
#import <ContextLocation/QLContextPlaceConnector.h>

@interface BeaconManager : NSObject <FYXVisitDelegate>
@property (nonatomic) FYXVisitManager *visitManager;
-(id)init;

@end
