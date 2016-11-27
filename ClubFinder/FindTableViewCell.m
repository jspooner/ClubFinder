//
//  FindTableViewCell.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/27/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "FindTableViewCell.h"

@implementation FindTableViewCell {
}

-(void)switchChanged:(UISwitch*)sender
{
    NSDictionary *dictionary = @{
                                 @"transmitterName" : self.transmitterNameLabel.text,
                                 @"transmitterIdentifier" : self.transmitterIdentifier
                                 };
    if ([sender isOn]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterAdded"
                                                            object:self
                                                          userInfo:dictionary];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"transmitterRemoved"
                                                            object:self
                                                          userInfo:dictionary];
    }
}

- (void)awakeFromNib
{
    // Initialization code
    [self.bagSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
}

// Method to re-arrange subviews within the custom cell
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.0f];
    
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
            
            // Correctly align the delete button within the custom cell
            CGRect newFrame = subview.frame;
            newFrame.origin.x = 230;
            newFrame.origin.y = -9;
            subview.frame = newFrame;
        }
    }
    [UIView commitAnimations];
}

@end
