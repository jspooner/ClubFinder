//
//  AppDelegate.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 2/20/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FYX/FYX.h>
#import "LocationLogger.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, FYXServiceDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LocationLogger *locationLogger;

@end
