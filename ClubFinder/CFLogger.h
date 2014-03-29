//
//  CFLogger.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 3/29/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFLogger : NSObject

+(CFLogger *)sharedInstance;
-(void)logEvent:(NSString*)event;

@end
