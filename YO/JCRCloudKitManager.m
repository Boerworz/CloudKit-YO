//
//  JCRCloudKitManager.m
//  YO
//
//  Created by César Manuel Pinto Castillo on 07/08/14.
//  Copyright (c) 2014 JagCesar. All rights reserved.
//

#import "JCRCloudKitManager.h"
@import CloudKit;

@implementation JCRCloudKitManager

+ (void)registerUsername:(NSString*)username
            successBlock:(void(^)())successBlock
            failureBlock:(void(^)(NSError* error))failureBlock {
    [[self __publicDatabase] performQuery:[[CKQuery alloc] initWithRecordType:@"usernames"
                                                                    predicate:[NSPredicate predicateWithFormat:@"username = %@", username]]
                             inZoneWithID:nil
                        completionHandler:^(NSArray *results, NSError *error) {
                            if (error || results.count > 0) {
                                dispatch_async(dispatch_get_main_queue(), ^{
#warning Create a proper error
                                    failureBlock(nil);
                                });
                            } else {
                                // Create username
                                CKRecord *record = [[CKRecord alloc] initWithRecordType:@"usernames"];
                                [record setObject:username
                                           forKey:@"username"];
                                [[self __publicDatabase] saveRecord:record
                                                  completionHandler:^(CKRecord *record, NSError *error) {
                                                      if (error) {
                                                          failureBlock(error);
                                                      } else {
                                                          [self __setupPushNotificationsForUsername:username];
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              successBlock();
                                                          });
                                                      }
                                                  }];
                            }
                        }];
}

#pragma mark - Private functions

+ (CKDatabase*)__publicDatabase {
    return [[CKContainer defaultContainer] publicCloudDatabase];
}

+ (void)__setupPushNotificationsForUsername:(NSString*)username {
    //    [[[CKContainer defaultContainer] publicCloudDatabase] fetchAllSubscriptionsWithCompletionHandler:^(NSArray *subscriptions, NSError *error) {
    //        for (CKSubscription *subscription in subscriptions) {
    //            [[[CKContainer defaultContainer] publicCloudDatabase] deleteSubscriptionWithID:[subscription subscriptionID]
    //                                                                         completionHandler:^(NSString *subscriptionID, NSError *error) {
    //                                                                             if (error) {
    //                                                                                 NSLog(@"Couldn't delete subsciption");
    //                                                                             } else {
    //                                                                                 NSLog(@"Deleted a subscription");
    //                                                                             }
    //                                                                         }];
    //        }
    //    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"to = %@", username];
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"YO"
                                                                    predicate:predicate
                                                                      options:CKSubscriptionOptionsFiresOnRecordCreation];
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
    [notificationInfo setDesiredKeys:@[@"to",@"from"]];
    [notificationInfo setAlertLocalizationArgs:@[@"from"]];
    [notificationInfo setAlertBody:@"%@ JUST YO:ED YOU!"];
    [notificationInfo setShouldBadge:YES];
    
    [subscription setNotificationInfo:notificationInfo];
    
    [[[CKContainer defaultContainer] publicCloudDatabase] saveSubscription:subscription
                                                         completionHandler:^(CKSubscription *subscription, NSError *error) {
                                                             if (error) {
#warning Handle error
                                                             } else {
#warning success
                                                             }
                                                         }];
}

@end
