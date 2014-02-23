//
//  ViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 2/20/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "ViewController.h"
#import "SightingsTableViewCell.h"
#import "Transmitter.h"
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
#pragma - mark TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // transmitters.count
    return 4;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyReusableCell";
    SightingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell != nil) {
//        Transmitter *transmitter = [self.transmitters objectAtIndex:indexPath.row];
        Transmitter *transmitter = [[Transmitter alloc] init];
        transmitter.name = @"Big Burtha";
        // Update the transmitter text
        cell.transmitterNameLabel.text = transmitter.name;
//
//        // Update the transmitter avatar (icon image)
//        NSInteger avatarID = [UserSettingsRepository getAvatarIDForTransmitterID:transmitter.identifier];
//        NSString *imageFilename = [NSString stringWithFormat:@"avatar_%02d.png", avatarID];
        cell.transmitterIcon.image = [UIImage imageNamed:@"Avatar"];
//
//        if ([self isTransmitterAgedOut:transmitter]) {
//            [self grayOutSightingsCell:cell];
//        } else {
//            [self updateSightingsCell:cell withTransmitter:transmitter];
//        }
    }
    return cell;
}


#pragma - mark
#pragma - mark Helpers

-(void)logMessage:(NSString*)message
{
    NSLog(@"%@",message);
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", message]];
    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
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
