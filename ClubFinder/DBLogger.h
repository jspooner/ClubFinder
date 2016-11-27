//
//  DBLogger.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/7/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDFileLogger.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DBLogger : DDLogFileManagerDefault <DBSessionDelegate, DBNetworkRequestDelegate, DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *restClient;

@end
