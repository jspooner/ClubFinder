//
//  DBLogger.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/7/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "DBLogger.h"

@implementation DBLogger

// Notifications from DDFileLogger
- (void)didArchiveLogFile:(NSString *)logFilePath
{
    NSLog(@"didArchiveLogFile %@", logFilePath);
}

- (void)didRollAndArchiveLogFile:(NSString *)logFilePath
{
    NSLog(@"didRollAndArchiveLogFile %@", logFilePath);
    NSString  *appKey = @"dw0ugacyw2y192e";
	NSString  *appSecret = @"qo57u9apjfw6x2i";
	NSString  *root = kDBRootAppFolder; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
    
    if ([session isLinked]) {
        if (self.restClient == NULL) {
            self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            self.restClient.delegate = self;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.restClient uploadFile:[self dropBoxPath:logFilePath] toPath:@"/" withParentRev:nil fromPath:logFilePath];
        });
    } else {
        NSLog(@"------------ SESSION IS NOT LINKED SO WE'RE NOT SENING LOGS");
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"File upload failed with error: %@", error);
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    NSLog(@"sessionDidReceiveAuthorizationFailure %@, %@", session, userId);
}

-(void)networkRequestStopped
{
    
}

-(void)networkRequestStarted
{
    
}

-(NSString*)dropBoxPath:(NSString *)filePath
{
#if DEBUG
    NSString *base = @"DEBUG/";
#else
    NSString *base = @"";
#endif
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    return [NSString stringWithFormat:@"%@/%@/%@", base, [oNSUUID UUIDString], [[filePath componentsSeparatedByString:@"/"] lastObject]];
}


@end
