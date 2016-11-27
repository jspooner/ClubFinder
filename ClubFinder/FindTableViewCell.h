//
//  FindTableViewCell.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/27/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *transmitterIcon;
@property (weak, nonatomic) IBOutlet UILabel *transmitterNameLabel;
@property (weak, nonatomic) NSString *transmitterIdentifier;
@property (weak, nonatomic) IBOutlet UIImageView *rssiImageView;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UISwitch *bagSwitch;

@property (nonatomic) BOOL isGrayedOut;

@end
