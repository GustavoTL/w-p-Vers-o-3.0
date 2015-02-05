//
//  WUPBaseDatabaseViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPBaseDatabaseViewController.h"

@interface WUPBaseDatabaseViewController ()

@end

@implementation WUPBaseDatabaseViewController

-(void) setupDatabaseConnection
{
    WUPAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
}

-(Alarm*) alarmFromNotificationUserInfo:(NSDictionary*) userInfoDict
{
    @try {
        NSURL *reconstructedClassURL = [NSURL URLWithString:[userInfoDict objectForKey:[WUPConstants OBJECT_ABSOLUTEURL_LOCALNOTIFICATION]]];
        NSURL *reconstructedInstanceURL = [reconstructedClassURL URLByAppendingPathComponent:[userInfoDict objectForKey:[WUPConstants OBJECT_LASTPATH_LOCALNOTIFICATION]]];
        NSManagedObjectID *objectID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:reconstructedInstanceURL];
        Alarm  *alarm = (Alarm*)[self.managedObjectContext objectWithID:objectID];
        return alarm;

    }
    @catch (NSException *exception) {
        return nil;
    }

}

@end
