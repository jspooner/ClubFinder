/**
 * Copyright (C) 2013 Qualcomm Retail Solutions, Inc. All rights reserved.
 *
 * This software is the confidential and proprietary information of Qualcomm
 * Retail Solutions, Inc.
 *
 * The following sample code illustrates various aspects of the FYX iOS SDK.
 *
 * The sample code herein is provided for your convenience, and has not been
 * tested or designed to work on any particular system configuration. It is
 * provided pursuant to the License Agreement for FYX Software and Developer
 * Portal AS IS, and your use of this sample code, whether as provided or with
 * any modification, is at your own risk. Neither Qualcomm Retail Solutions,
 * Inc. nor any affiliate takes any liability nor responsibility with respect
 * to the sample code, and disclaims all warranties, express and implied,
 * including without limitation warranties on merchantability, fitness for a
 * specified purpose, and against infringement.
 */
#import "Transmitter.h"

@implementation Transmitter

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeFloat:[self.rssi floatValue]  forKey:@"rssi"];
    [encoder encodeFloat:[self.previousRSSI floatValue]  forKey:@"previousRSSI"];
    [encoder encodeObject:self.lastSighted forKey:@"lastSighted"];
    [encoder encodeFloat:[self.batteryLevel floatValue]  forKey:@"batteryLevel"];
    [encoder encodeFloat:[self.temperature floatValue]  forKey:@"temperature"];
    [encoder encodeBool:self.inBag forKey:@"inBag"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.name = [decoder decodeObjectForKey:@"name"];
    self.identifier = [decoder decodeObjectForKey:@"identifier"];
    self.rssi = [NSNumber numberWithFloat:[decoder decodeFloatForKey:@"rssi"]];
    self.previousRSSI = [NSNumber numberWithFloat:[decoder decodeFloatForKey:@"previousRSSI"]];
    self.lastSighted = [decoder decodeObjectForKey:@"lastSighted"];
    self.batteryLevel = [NSNumber numberWithFloat:[decoder decodeFloatForKey:@"batteryLevel"]];
    self.temperature = [NSNumber numberWithFloat:[decoder decodeFloatForKey:@"temperature"]];
    self.inBag = [decoder decodeBoolForKey:@"inBag"];
    
    return self;
}

@end


//@property (nonatomic, strong) NSString *identifier;
//@property (nonatomic, strong) NSNumber *rssi;
//@property (nonatomic, strong) NSNumber *previousRSSI;
//@property (nonatomic, strong) NSDate *lastSighted;
//@property (nonatomic, strong) NSNumber *batteryLevel;
//@property (nonatomic, strong) NSNumber *temperature;
//@property (nonatomic, assign) BOOL inBag;
