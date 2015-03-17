//
//  WUPAppDelegate.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/29/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Alarm.h"

@protocol WUPAppDelegateLocationDelegate <NSObject>

- (void) willUpdateLocation:(CLLocation*)location;

@end

@interface WUPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Persistent properties
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator ;

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) Alarm * mCurentAlarm;
@property (strong,nonatomic)  NSObject *lastLocalNotification;

@property (nonatomic, strong) id <WUPAppDelegateLocationDelegate> delegate;

- (void) currentAlarm:(Alarm*) alarm;

@end
