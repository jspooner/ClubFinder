//
//  LeftViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/27/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "BeaconViewController.h"
#import "MyBagViewController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.myBagButton addTarget:self action:@selector(myBagClick) forControlEvents:UIControlEventTouchUpInside];
    [self.manageBagButton addTarget:self action:@selector(manageBagClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)myBagClick
{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    self.viewDeckController.centerController = [[MyBagViewController alloc] initWithBeacon:appDelegate.beaconManager];
//    [self.viewDeckController closeLeftViewAnimated:YES];
}

-(void)manageBagClick
{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    self.viewDeckController.centerController = [[BeaconViewController alloc] initWithBeacon:appDelegate.beaconManager];
//    [self.viewDeckController closeLeftViewAnimated:YES];
}

@end
