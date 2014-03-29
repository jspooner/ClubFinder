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
#import <UIKit/UILocalNotification.h>
#import "CFLogger.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *transmitters;
@property (nonatomic) FYXVisitManager *visitManager;
@property (nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTransmitters];
    self.visitManager = [FYXVisitManager new];
    self.visitManager.delegate = self;
    [self.visitManager start];
}

#pragma - mark
#pragma - mark Helpers

//-(void)logMessage:(NSString*)message
//{
//    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//    NSLog(@"[%@][%f] log?%@", appVersion, timeInMiliseconds, message);
////    @synchronized(self) {
////        self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", message]];
////        [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
////    }
//}

- (NSNumber *)rssiForBarWidth:(float)barWidth {
    NSInteger barMaxValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_max_value"];
    NSInteger barMinValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"rssi_bar_min_value"];
    
    NSInteger barRange = barMaxValue - barMinValue;
    float percentage = - ((barWidth / 270.0f) - 1.0f);
    float rssiValue = - ((percentage * (float)barRange) - barMaxValue);
    
    return [NSNumber numberWithFloat:rssiValue];
}

#pragma mark
#pragma mark - User interface manipulation

- (void)hideNoTransmittersView {
    // Simply set a background image for the table view
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundView:backgroundImageView];
//    [self.spinnerImageView stopAnimating];
}

- (void)showNoTransmittersView {
    CGRect viewFrame = self.tableView.frame;
    
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:22.0f];
    label.text = @"Scanning...";
    [label sizeToFit];
    label.center = CGPointMake(viewFrame.size.width / 2, (viewFrame.size.height / 2) - 40);
    [view addSubview:label];
//    self.spinnerImageView.frame = CGRectMake(viewFrame.size.width / 2 - 25, (viewFrame.size.height / 2) - 105, 50, 50);
//    [self.spinnerImageView startAnimating];
//    [view addSubview:self.spinnerImageView];
    [self.tableView setBackgroundView:view];
}


#pragma mark
#pragma mark - Transmitters manipulation

- (void)initializeTransmitters {
    // Re-create the transmitters container array
    [self showNoTransmittersView];
    @synchronized(self.transmitters){
        if (self.transmitters == nil) {
            self.transmitters = [NSMutableArray new];
        }
        // Always reload the table (even if the transmitter list didn't change)
        [self.tableView reloadData];
    }
}

- (void)addTransmitter: (Transmitter *)transmitter
{
    @synchronized(self.transmitters){
        [self.transmitters addObject:transmitter];
        if([self.transmitters count] == 1){
            [self hideNoTransmittersView];
        }
    }
}

- (BOOL)shouldUpdateTransmitterCell:(FYXVisit *)visit withTransmitter:(Transmitter *)transmitter RSSI:(NSNumber *)rssi{
    if (![transmitter.rssi isEqual:rssi] || ![transmitter.batteryLevel isEqualToNumber:visit.transmitter.battery]
        || ![transmitter.temperature isEqualToNumber:visit.transmitter.temperature]){
        return YES;
    }
    else {
        return NO;
    }
}

- (void)updateTransmitter:(Transmitter *)transmitter withVisit:(FYXVisit *)visit RSSI:(NSNumber *)rssi {
    transmitter.previousRSSI = transmitter.rssi;
    transmitter.rssi = rssi;
    transmitter.batteryLevel = visit.transmitter.battery;
    transmitter.temperature = visit.transmitter.temperature;
}

- (void)updateSightingsCell:(SightingsTableViewCell *)sightingsCell withTransmitter:(Transmitter *)transmitter {
//    if (sightingsCell && transmitter) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            sightingsCell.contentView.alpha = 1.0f;
//            
//            float oldBarWidth = [self barWidthForRSSI:transmitter.previousRSSI];
//            float newBarWidth = [self barWidthForRSSI:transmitter.rssi];
//            CGRect tempFrame = sightingsCell.rssiImageView.frame;
//            CGRect oldFrame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, oldBarWidth, tempFrame.size.height);
//            CGRect newFrame = CGRectMake(tempFrame.origin.x, tempFrame.origin.y, newBarWidth, tempFrame.size.height);
//            
//            // Animate updating the RSSI indicator bar
//            sightingsCell.rssiImageView.frame = oldFrame;
//            [UIView animateWithDuration:1.0f animations:^{
//                sightingsCell.rssiImageView.frame = newFrame;
//            }];
//            sightingsCell.isGrayedOut = NO;
//            UIImage *batteryImage = [self getBatteryImageForLevel:transmitter.batteryLevel];
//            [sightingsCell.batteryImageView setImage:batteryImage];
//            sightingsCell.temperature.text = [NSString stringWithFormat:@"%@%@", transmitter.temperature,
//                                              [NSString stringWithUTF8String:"\xC2\xB0 F" ]];
//            sightingsCell.rssiLabel.text = [NSString stringWithFormat:@"%@", transmitter.rssi];
//            
//        });
//    }
}

- (Transmitter *)transmitterForID:(NSString *)ID {
    for (Transmitter *transmitter in self.transmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    return nil;
}

- (void)clearTransmitters {
    [self showNoTransmittersView];
    @synchronized(self.transmitters){
        [self.transmitters removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)removeTransmitter: (Transmitter*)transmitter {
    NSInteger count = 0;
    @synchronized(self.transmitters){
        [self.transmitters removeObject:transmitter];
        count =[self.transmitters count];
    }
    if(count == 0){
        [self showNoTransmittersView];
    }
}

- (BOOL)isTransmitterAgedOut:(Transmitter *)transmitter {
    NSDate *now = [NSDate date];
    NSTimeInterval ageOutPeriod = [[NSUserDefaults standardUserDefaults] integerForKey:@"age_out_period"];
    if ([now timeIntervalSinceDate:transmitter.lastSighted] > ageOutPeriod) {
        return YES;
    }
    return NO;
}

#pragma - mark
#pragma - mark TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transmitters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyReusableCell";
    SightingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell != nil) {
        Transmitter *transmitter = [self.transmitters objectAtIndex:indexPath.row];
        // Update the transmitter text
        cell.transmitterNameLabel.text = transmitter.name;

        // Update the transmitter avatar (icon image)
//        NSInteger avatarID = [UserSettingsRepository getAvatarIDForTransmitterID:transmitter.identifier];
//        NSString *imageFilename = [NSString stringWithFormat:@"avatar_%02d.png", avatarID];
        cell.transmitterIcon.image = [UIImage imageNamed:@"Avatar"];

//        if ([self isTransmitterAgedOut:transmitter]) {
//            [self grayOutSightingsCell:cell];
//        } else {
//            [self updateSightingsCell:cell withTransmitter:transmitter];
//        }
    }
    return cell;
}

#pragma - mark
#pragma - mark FYXVisitDelegate

- (void)didArrive:(FYXVisit *)visit
{
    // this will be invoked when an authorized transmitter is sighted for the first time
    NSArray *params = @[
                       @"e=/beacon/didArrive",
                       [@[@"identifer", visit.transmitter.identifier] componentsJoinedByString:@"="],
                       [@[@"name", visit.transmitter.name] componentsJoinedByString:@"="],
                       [@[@"ownerId", visit.transmitter.ownerId] componentsJoinedByString:@"="],
                       [@[@"battery", visit.transmitter.battery] componentsJoinedByString:@"="],
                       [@[@"temperature", visit.transmitter.temperature] componentsJoinedByString:@"="]
                       ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
}

- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;
{
    // this will be invoked when an authorized transmitter is sighted during an on-going visit
    NSArray *params = @[
                        @"e=/beacon/receivedSighting",
                        [@[@"identifer", visit.transmitter.identifier] componentsJoinedByString:@"="],
                        [@[@"name", visit.transmitter.name] componentsJoinedByString:@"="],
                        [@[@"ownerId", visit.transmitter.ownerId] componentsJoinedByString:@"="],
                        [@[@"battery", visit.transmitter.battery] componentsJoinedByString:@"="],
                        [@[@"temperature", visit.transmitter.temperature] componentsJoinedByString:@"="],
                        [@[@"updateTime", updateTime] componentsJoinedByString:@"="],
                        [@[@"rssi", RSSI] componentsJoinedByString:@"="],
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
    
    Transmitter *transmitter = [self transmitterForID:visit.transmitter.identifier];
    if (!transmitter) {
        NSString *transmitterName = visit.transmitter.identifier;
        if(visit.transmitter.name){
            transmitterName = visit.transmitter.name;
        }
        transmitter = [Transmitter new];
        transmitter.identifier = visit.transmitter.identifier;
        transmitter.name = transmitterName;
        transmitter.lastSighted = [NSDate dateWithTimeIntervalSince1970:0];
        transmitter.rssi = [NSNumber numberWithInt:-100];
        transmitter.previousRSSI = transmitter.rssi;
        transmitter.batteryLevel = 0;
        transmitter.temperature = 0;
        [self addTransmitter:transmitter];
        [self.tableView reloadData];
    }

    transmitter.lastSighted = updateTime;
    if([self shouldUpdateTransmitterCell:visit withTransmitter:transmitter RSSI:RSSI]){
        [self updateTransmitter:transmitter withVisit:visit  RSSI:RSSI];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.transmitters indexOfObject:transmitter] inSection:0];
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            if ([[self.tableView indexPathForCell:cell] isEqual:indexPath]) {
                SightingsTableViewCell *sightingsCell = (SightingsTableViewCell *)cell;
                
                CALayer *tempLayer = [sightingsCell.rssiImageView.layer presentationLayer];
                transmitter.previousRSSI =  [self rssiForBarWidth:[tempLayer frame].size.width];
                
                [self updateSightingsCell:sightingsCell withTransmitter:transmitter];
            }
        }
    }
}

- (void)didDepart:(FYXVisit *)visit
{
    // this will be invoked when an authorized transmitter has not been sighted for some time
    NSArray *params = @[
                        @"e=/beacon/didDepart",
                        [@[@"identifer", visit.transmitter.identifier] componentsJoinedByString:@"="],
                        [@[@"name", visit.transmitter.name] componentsJoinedByString:@"="],
                        [@[@"ownerId", visit.transmitter.ownerId] componentsJoinedByString:@"="],
                        [@[@"battery", visit.transmitter.battery] componentsJoinedByString:@"="],
                        [@[@"temperature", visit.transmitter.temperature] componentsJoinedByString:@"="],
                        [@[@"dwellTime", [NSString stringWithFormat:@"%f", visit.dwellTime]] componentsJoinedByString:@"="]
                        ];
    [[CFLogger sharedInstance] logEvent:[params componentsJoinedByString:@"&"]];
    //
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
            UILocalNotification *myNote = [[UILocalNotification alloc] init];
            myNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
            myNote.timeZone = [NSTimeZone defaultTimeZone];
            myNote.alertBody = [NSString stringWithFormat:@"Left proximity of a Gimbal Beacon!!!! %@ I was around the beacon for %f seconds", visit.transmitter.name, visit.dwellTime];
            myNote.alertAction = @"View Details";
            myNote.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:myNote];
        } else {
            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"I left the proximity of a Gimbal Beacon!!!! %@", visit.transmitter.name]
                                        message:[NSString stringWithFormat:@"I was around the beacon for %f seconds", visit.dwellTime]
                                       delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] show];
        }
    }];
    
    
}

@end
