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
#import <ContextLocation/QLPlaceEvent.h>
#import <ContextLocation/QLPlace.h>
#import <FYX/FYXLogging.h>
#import "DBLogger.h"
#import <ContextCore/QLContextCoreConnector.h>
#import "IIViewDeckController.h"
#import <GoogleMaps/GoogleMaps.h>

#import "BeaconViewController.h"
#import "MyBagViewController.h"
#import "HomeViewController.h"
#import "LeftViewController.h"
#import "SplashViewController.h"

@implementation AppDelegate

-(void)setupLogging
{
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DBLogger alloc] init]];
    [fileLogger setRollingFrequency:60 * 60 * 0.5];         // Every 1/2 Hour
    [fileLogger setMaximumFileSize:1024 * 1024 * 1];        // 1mb
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:3];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:fileLogger];
}

-(void)initPlaceConnector
{
    NSLog(@"initPlaceConnector");
    [self showBeaconViewController];
//    [FYXLogging setLogLevel:FYX_LOG_LEVEL_VERBOSE];
//    [FYX setAppId:@"ff0cc75b23cc0b03cb266cf617908c0aed6f03bd549dd7d6bc58da64b4d0fb90"
//        appSecret:@"2acc48534c2c20ad470cc3ec5c947e51d71126bafc39c2b1075675dd72a235fa"
//      callbackUrl:@"clubfinder://authcode"];
//    [FYX startService:self];
    // Geofence
    self.placeConnector = [[QLContextPlaceConnector alloc] init];
    self.placeConnector.delegate = self;
    [self.placeConnector monitorPlacesInBackground];
    [self.placeConnector monitorPlacesWhenAllowed];
    NSLog(self.placeConnector.isPlacesEnabled ? @"placeConnector.isPlacesEnabled=Yes" : @"placeConnector.isPlacesEnabled=No");
    NSLog(self.placeConnector.isBackgroundPlaceMonitoringEnabled ? @"placeConnector.isBackgroundPlaceMonitoringEnabled=Yes" : @"placeConnector.isBackgroundPlaceMonitoringEnabled=No");
//    [self.placeConnector allOrganizationPlacesAndOnSuccess:^(NSArray *places) {
//        NSLog(@"allOrganizationPlacesAndOnSuccess SUCCESS %@", places);
//    } failure:^(NSError *error) {
//        NSLog(@"allOrganizationPlacesAndOnSuccess ERROR %@", error);
//    }];
//    [self.placeConnector allPrivatePointsOfInterestAndOnSuccess:^(NSArray *privatePointsOfInterest) {
//        NSLog(@"allPrivatePointsOfInterestAndOnSuccess SUCCESS %@", privatePointsOfInterest);
//    } failure:^(NSError *error) {
//        NSLog(@"allPrivatePointsOfInterestAndOnSuccess ERROR %@", error);
//    }];
//    [self.placeConnector allPlacesAndOnSuccess:^(NSArray *places) {
//        NSLog(@"allPlacesAndOnSuccess SUCCESS %@", places);
//    } failure:^(NSError *error) {
//        NSLog(@"allPlacesAndOnSuccess ERROR %@", error);
//    }];
}
- (void)enableContextCoreConnector
{
    QLContextCoreConnector *connector = [QLContextCoreConnector new];
    [connector checkStatusAndOnEnabled:^(QLContextConnectorPermissions *contextConnectorPermissions) {
        NSLog(@"Gimbal is enabled");
        [self initPlaceConnector];
    } disabled:^(NSError *error) {
        NSLog(@"Gimbal was disabled %@", error);
        [connector enableFromViewController:self.window.rootViewController success:^{
            NSLog(@"Gimbal enabled");
            [self initPlaceConnector];
        } failure:^(NSError *error) {
            NSLog(@"Failed to initialize gimbal %@", error);
        }];
    }];
}

-(void)showBeaconViewController
{
    NSLog(@"showBeaconViewController");
    MyBagViewController *myBagVC = [[MyBagViewController alloc] initWithBeacon:self.beaconManager];
    self.centerController.viewDeckController.centerController = [[UINavigationController alloc] initWithRootViewController:myBagVC];
//    if ([self.beaconManager.mySavedTransmitters count] > 0) {
//        self.centerController.viewDeckController.centerController = [[MyBagViewController alloc] initWithBeacon:self.beaconManager];
//    } else {
//        self.centerController.viewDeckController.centerController = [[BeaconViewController alloc] initWithBeacon:self.beaconManager];
//    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:@"AIzaSyCYB4t6qnN5LyQ5denPgmyPS7Qvn6mVPiA"];
    [self setupLogging];
    self.locationLogger = [[LocationTracker alloc] init];
    self.beaconManager = [[BeaconManager alloc] initWith:self.locationLogger];
    [self.locationLogger startTracking];
    
    self.leftController = [[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil];
    SplashViewController *splashViewController = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
    self.centerController = [[UINavigationController alloc] initWithRootViewController:splashViewController];
    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:self.centerController
                                                                                   leftViewController:self.leftController];
    [deckController setParallaxAmount:0.08];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = deckController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    NSMutableArray *params = @[@"e=/app/applicationDidFinishLaunching"].mutableCopy;
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        [params addObject:[@[@"alertAction", localNotif.alertAction] componentsJoinedByString:@"="]];
    }
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
    [self enableContextCoreConnector];
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
    [[CFLogger sharedInstance] logEvent:@"e=/app/applicationDidBecomeActive"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CFLogger sharedInstance] logEvent:@"e=app/applicationWillTerminate"];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[CFLogger sharedInstance] logEvent:[NSString stringWithFormat:@"e=app/didReceiveRemoteNotification?userInfo=%@", userInfo]];
}
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{}

#pragma - mark
#pragma - mark Dropbox

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

//#pragma - mark
//#pragma - mark FYX
//
//- (void)serviceStarted
//{
//    // this will be invoked if the service has successfully started
//    // bluetooth scanning will be started at this point.
//    [[CFLogger sharedInstance] logEvent:@"e=app/gimbal/serviceStarted"];
//}
//
//- (void)startServiceFailed:(NSError *)error
//{
//    // this will be called if the service has failed to start
//    [[CFLogger sharedInstance] logEvent: [NSString stringWithFormat:@"e=app/gimbal/startServiceFailed&error=%@", error]];
//}

#pragma - mark
#pragma - mark Geofence

- (void)didGetPlaceEvent:(QLPlaceEvent *)placeEvent
{
    NSLog(@"[geofence] did get place event %@, placeType=%i", [placeEvent place].name, placeEvent.placeType);
    [[CFLogger sharedInstance] logEvent:[NSString stringWithFormat:@"e=app/gimbal/geofence/didGetPlaceEvent&placeName=%@&evenType=%i", [placeEvent place].name, placeEvent.eventType ] ];
    // Test Notification
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"HH:mm:ss"];
            NSDate *now =  [NSDate dateWithTimeIntervalSinceNow:1];
            NSString *theDate = [dateFormat stringFromDate:now];
            NSString *theTime = [timeFormat stringFromDate:now];
            NSLog(@"\n"
                  "theDate: |%@| \n"
                  "theTime: |%@| \n"
                  , theDate, theTime);
            UILocalNotification *myNote = [[UILocalNotification alloc] init];
            myNote.fireDate =  now;
            myNote.timeZone = [NSTimeZone defaultTimeZone];
            if (placeEvent.eventType == QLPlaceEventTypeAt ) {
                myNote.alertBody = [NSString stringWithFormat:@"Welcome to %@", placeEvent.place.name];
            } else {
                myNote.alertBody = [NSString stringWithFormat:@"Thank you for visiting %@", placeEvent.place.name];
            }
            
            myNote.alertAction = @"View Details";
            myNote.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:myNote];
        } else {
            UIStoryboard *storyboard = [[[self window] rootViewController] storyboard];
            HomeViewController *hvc = (HomeViewController*)[storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
            [hvc performSegueWithIdentifier:@"fuckThis" sender:nil];
        }
    }];
}

- (void)didGetContentDescriptors:(NSArray *)contentDescriptors
{
    NSLog(@"didGetContentDescriptors %@", contentDescriptors);
    [[CFLogger sharedInstance] logEvent:[NSString stringWithFormat:@"e=app/gimbal/geofence/didGetContentDescriptors&contentDescriptors=%@", contentDescriptors]];
}

- (void)placesPermissionDidChange:(BOOL)placesPermission
{
    NSLog(@"placesPermissionDidChange %hhd", placesPermission);
}

- (void)privatePlacesDidChange:(NSArray *)privatePlaces
{
    NSLog(@"privatePlacesDidChange %@", privatePlaces);
}

- (BOOL)shouldMonitorPlace:(QLPlace *)place
{
    NSLog(@"shouldMonitorPlace %@", place.name);
    return YES;
}



@end
