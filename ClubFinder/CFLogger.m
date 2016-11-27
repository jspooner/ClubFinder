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
    
    // START ALERT OF NOTIFICATION
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    NSString *currentState = nil;
    if (state == UIApplicationStateActive)
    {
        currentState = @"&state=UIApplicationStateActive";
    }
    else if (state == UIApplicationStateBackground)
    {
        currentState = @"&state=UIApplicationStateBackground";
    }
    else if (state == UIApplicationStateInactive)
    {
        currentState = @"&state=UIApplicationStateInactive";
    }
    
    DDLogVerbose(@"[%@][%f] log?%@%@", appVersion, timeInMiliseconds, event, currentState);
}

@end
