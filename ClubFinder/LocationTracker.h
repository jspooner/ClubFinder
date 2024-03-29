//
//  LocationLogger.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 3/28/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (strong) CLLocation *lastLocation;
@property (strong) NSDate *lastLocationTimestamp;

-(void)startTracking;
-(void)stopTracking;

@end
