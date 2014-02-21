//
//  ViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 2/20/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "ViewController.h"
#import <FYX/FYXVisitManager.h>
#import <FYX/FYXTransmitter.h>

@interface ViewController ()
@property (nonatomic) FYXVisitManager *visitManager;
@property (nonatomic) IBOutlet UITextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.visitManager = [FYXVisitManager new];
    self.visitManager.delegate = self;
    [self.visitManager start];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark
#pragma - mark Helpers

-(void)logMessage:(NSString*)message
{
    NSLog(message);
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", message]];
}

#pragma - mark
#pragma - mark FYXVisitDelegate

- (void)didArrive:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter is sighted for the first time
    [self logMessage:[NSString stringWithFormat:@"I arrived at a Gimbal Beacon!!! %@", visit.transmitter.name]];
}

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    [self logMessage:[NSString stringWithFormat:@"I received a sighting!!! %@ (%@)", visit.transmitter.name, RSSI]];
}

- (void)didDepart:(FYXVisit *)visit;
{
    // this will be invoked when an authorized transmitter has not been sighted for some time
    [self logMessage:[NSString stringWithFormat:@"I left the proximity of a Gimbal Beacon!!!! %@", visit.transmitter.name]];
    [self logMessage:[NSString stringWithFormat:@"I was around the beacon for %f seconds", visit.dwellTime]];
}

@end
