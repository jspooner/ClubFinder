//
//  AppDelegate.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 2/20/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "AppDelegate.h"
#import <DDLog.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import "CFLogger.h"

@implementation AppDelegate

-(void)setupLogging
{
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setRollingFrequency:60 * 60 * 24];
    [fileLogger setMaximumFileSize:1024 * 1024 * 4];
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:30];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:fileLogger];
}

-(void)setupGimbal
{
    [FYX setAppId:@"ff0cc75b23cc0b03cb266cf617908c0aed6f03bd549dd7d6bc58da64b4d0fb90"
        appSecret:@"2acc48534c2c20ad470cc3ec5c947e51d71126bafc39c2b1075675dd72a235fa"
      callbackUrl:@"clubfinder://"];
    [FYX startService:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupLogging];
    [self setupGimbal];
    self.locationLogger = [[LocationLogger alloc] init];
    [[CFLogger sharedInstance] logEvent:@"e=app/applicationDidFinishLaunching"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[CFLogger sharedInstance] logEvent:@"e=app/applicationWillResignActive"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[CFLogger sharedInstance] logEvent:@"e=app/applicationDidEnterBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[CFLogger sharedInstance] logEvent:@"e=app/applicationWillEnterForeground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[CFLogger sharedInstance] logEvent:@"e=app/applicationDidBecomeActive"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CFLogger sharedInstance] logEvent:@"e=app/applicationWillTerminate"];
}

- (void)serviceStarted
{
    // this will be invoked if the service has successfully started
    // bluetooth scanning will be started at this point.
    [[CFLogger sharedInstance] logEvent:@"e=app/gimbal/serviceStarted"];
}

- (void)startServiceFailed:(NSError *)error
{
    // this will be called if the service has failed to start
    [[CFLogger sharedInstance] logEvent: [NSString stringWithFormat:@"e=app/gimbal/startServiceFailed&error=%@", error]];
}

@end
