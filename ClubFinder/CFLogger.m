//
//  CFLogger.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 3/29/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "CFLogger.h"

@implementation CFLogger

static CFLogger *sharedSingleton;

+(CFLogger *)sharedInstance
{
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[CFLogger alloc] init];
        
        return sharedSingleton;
    }
}

-(void)logEvent:(NSString*)event
{
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSLog(@"[%@][%f] log?%@", appVersion, timeInMiliseconds, event);
}

@end
