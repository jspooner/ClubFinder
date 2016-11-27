//
//  SightingsTableViewCell.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 2/23/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "SightingsTableViewCell.h"

@implementation SightingsTableViewCell

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