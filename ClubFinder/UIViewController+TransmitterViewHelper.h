//
//  UIViewController+TransmitterViewHelper.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 5/1/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transmitter.h"

@interface UIViewController (TransmitterViewHelper)
- (UIImage *)getBatteryImageForLevel: (NSNumber *)batteryLevel;
- (float)barWidthForRSSI:(NSNumber *)rssi;
- (NSNumber *)rssiForBarWidth:(float)barWidth;
- (BOOL)isTransmitterAgedOut:(Transmitter *)transmitter;
@end
