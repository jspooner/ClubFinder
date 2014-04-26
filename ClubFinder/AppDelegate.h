//
//  AppDelegate.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 2/20/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FYX/FYX.h>
#import "LocationTracker.h"
#import <ContextLocation/QLContextPlaceConnector.h>
#import "HomeViewController.h"
#import "BeaconManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, FYXServiceDelegate, QLContextPlaceConnectorDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LocationTracker *locationLogger;
@property (strong, nonatomic) BeaconManager *beaconManager;
@property (nonatomic) QLContextPlaceConnector *placeConnector;
@property (retain, nonatomic) UINavigationController *centerController;
@property (retain, nonatomic) UIViewController *leftController;

@end
