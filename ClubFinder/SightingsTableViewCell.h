//
//  SightingsTableViewCell.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 2/23/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SightingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *transmitterIcon;
@property (weak, nonatomic) IBOutlet UILabel *transmitterNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rssiImageView;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;


@property (nonatomic) BOOL isGrayedOut;

@end
