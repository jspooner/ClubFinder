//
//  UIViewController+TransmitterViewHelper.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 5/1/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "UIViewController+TransmitterViewHelper.h"

@implementation UIViewController (TransmitterViewHelper)

- (UIImage *)getBatteryImageForLevel: (NSNumber *)batteryLevel
{
    switch([batteryLevel integerValue]){
        case 0:
        case 1:
            return [UIImage imageNamed:@"battery_low.png"];
        case 2:
            return [UIImage imageNamed:@"battery_high.png"];
        case 3:
            return [UIImage imageNamed:@"battery_full.png"];
    }
    return [UIImage imageNamed:@"battery_unknown.png"];
}

- (NSNumber *)rssiForBarWidth:(float)barWidth
{
    NSInteger barMaxValue = -60; // [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_max_value"];
    NSInteger barMinValue = -90; // [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_min_value"];
    
    NSInteger barRange = barMaxValue - barMinValue;
    float percentage = - ((barWidth / 270.0f) - 1.0f);
    float rssiValue = - ((percentage * (float)barRange) - barMaxValue);
    
    return [NSNumber numberWithFloat:rssiValue];
}

- (float)barWidthForRSSI:(NSNumber *)rssi
{
    NSInteger barMaxValue = -60; //[[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_max_value"];
    NSInteger barMinValue = -90; // [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_min_value"];
    
    float rssiValue = [rssi floatValue];
    float barWidth;
    if (rssiValue >= barMaxValue) {
        barWidth = 270.0f;
    } else if (rssiValue <= barMinValue) {
        barWidth = 5.0f;
    } else {
        NSInteger barRange = barMaxValue - barMinValue;
        float percentage = (barMaxValue - rssiValue) / (float)barRange;
        barWidth = (1.0f - percentage) * 270.0f;
    }
    return barWidth;
}

- (BOOL)isTransmitterAgedOut:(Transmitter *)transmitter
{
    NSDate *now = [NSDate date];
    NSTimeInterval ageOutPeriod = 15; //[[NSUserDefaults standardUserDefaults] integerForKey:@"age_out_period"];
    if ([now timeIntervalSinceDate:transmitter.lastSighted] > ageOutPeriod) {
        return YES;
    }
    return NO;
}

@end
