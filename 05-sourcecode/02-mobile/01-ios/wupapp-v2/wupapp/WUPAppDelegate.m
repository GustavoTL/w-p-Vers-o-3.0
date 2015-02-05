//
//  WUPAppDelegate.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/29/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPAppDelegate.h"
#import "WUPHomeViewController.h"

@implementation WUPAppDelegate

//Persistent properties
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    [application setMinimumBackgroundFetchInterval:60*60]; //1 hour
    
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    NSTimeInterval interval = 60 * 60;
    [application setMinimumBackgroundFetchInterval:interval];
    
    // Initialize Google Analytics tracking
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-55004640-1"];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // The following line must only run under iOS 8. This runtime check prevents
    // it from running if it doesn't exist (such as running under iOS 7 or earlier).
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
#endif
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
        
        //Check whether it has become active due to a Time To Leave Notification
        if([localNotification.userInfo objectForKey:[WUPConstants OBJECT_TIMETOLEAVE_LOCALNOTIFICATION]]){
            UITabBarController* tab = (UITabBarController*)self.window.rootViewController;
            [tab setSelectedIndex:2]; //Sending to Route Screen
        }
        
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    UIApplicationState state = [application applicationState];
    NSDictionary* userInfo = notification.userInfo;
    
    NSString* master = [userInfo objectForKey:[WUPConstants OBJECT_MASTER_LOCALNOTIFICATION]];
    
    NSString* timeToLeave = [userInfo objectForKey:[WUPConstants OBJECT_TIMETOLEAVE_LOCALNOTIFICATION]];
    
    if (state == UIApplicationStateActive) {
        if(master){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarme"
                                                            message:notification.alertBody
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
//        else if(timeToLeave){
//            UITabBarController* tab = (UITabBarController*)self.window.rootViewController;
//            [tab setSelectedIndex:2];
//        }
    } else if(state == UIApplicationStateInactive){
        if(timeToLeave){
            UITabBarController* tab = (UITabBarController*)self.window.rootViewController;
            [tab setSelectedIndex:2];
        }
    }
    
    application.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    
    NSArray* arrayNotifications = [application scheduledLocalNotifications];
    
    NSLog(@"AQUI %@" , arrayNotifications);
    
    for(int i = 0; i < [arrayNotifications count]; i++){
        UILocalNotification *local = [arrayNotifications objectAtIndex:i];
        
        NSDictionary* userInfo = local.userInfo;
        
        NSString* master = [userInfo objectForKey:[WUPConstants OBJECT_MASTER_LOCALNOTIFICATION]];
        
        NSLog(@"master: %@", master);
        
        if(master){
            NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
        }
        
    }
    
    
    NSURL *URL = [NSURL URLWithString:@"http://route.cit.api.here.com/routing/7.2/calculateroute.json?app_id=GE8gkD7FPvvaTXP0cXWM&app_code=NCGRlH4IuN5_GXJt_ccLAg&mode=fastest;car;traffic:enabled&waypoint0=geo!-23.607810,-46.665650&waypoint1=geo!-23.602459,-46.661167"];
    
    NSLog(@"URL -> %@", [URL path]);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON DELEGATE: %@", responseObject);
        
        @try {
            NSDictionary* responseJSONObj = [responseObject objectForKey:@"response"];
            NSArray* routeArray = [responseJSONObj objectForKey:@"route"];
            NSDictionary* summaryJSONObj = [[routeArray firstObject] objectForKey:@"summary"];
            //We add a padding value to ensure people will get there even earlier than expected
            
            int distance = [[summaryJSONObj objectForKey:@"trafficTime"] intValue];
            int trafficTime = [[summaryJSONObj objectForKey:@"trafficTime"] intValue] + [WUPConstants NUMBER_PADDING_ALARMS:distance];
            
            NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:1];//-60*15
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            
            // [formatter3 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [formatter3 setTimeStyle:NSDateFormatterShortStyle];
            [formatter3 setDateStyle:NSDateFormatterShortStyle];
            
            NSString *detailstext = [formatter3 stringFromDate:newDate];
            NSDate *othernewdate = [formatter3 dateFromString:detailstext];
            
            NSString *message = [@"15 minutes until " stringByAppendingString:[NSString stringWithFormat:@"%d", trafficTime]];
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.timeZone = [NSTimeZone systemTimeZone];
            notification.fireDate = othernewdate;
            notification.alertBody = message;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.hasAction = YES;
            notification.alertAction = NSLocalizedString(@"View", @"View notification button");
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
        } @catch (NSException *exception) {
            NSLog(@"NSException: %@", exception.description);
        }
        
        completionHandler(UIBackgroundFetchResultNewData);
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completionHandler(UIBackgroundFetchResultFailed);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
    
    
//    UITabBarController* tab = (UITabBarController*)self.window.rootViewController;
//    WUPHomeViewController *homeController = [tab.viewControllers objectAtIndex:0];
//    
//    [homeController updateTrafficLocationNotification:^(UIBackgroundFetchResult result) {
//        
//        NSLog(@"AQUI");
//        
//        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:1];//-60*15
//        NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
//        
//        // [formatter3 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//        [formatter3 setTimeStyle:NSDateFormatterShortStyle];
//        [formatter3 setDateStyle:NSDateFormatterShortStyle];
//        
//        NSString *detailstext = [formatter3 stringFromDate:newDate];
//        NSDate *othernewdate = [formatter3 dateFromString:detailstext];
//        
//        NSString *message = [@"15 minutes until " stringByAppendingString:detailstext];
//        
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.timeZone = [NSTimeZone systemTimeZone];
//        notification.fireDate = othernewdate;
//        notification.alertBody = message;
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        notification.hasAction = YES;
//        notification.alertAction = NSLocalizedString(@"View", @"View notification button");
//        
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//        
//    }];
    
//    NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:1];//-60*15
//    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
//    
//    // [formatter3 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    [formatter3 setTimeStyle:NSDateFormatterShortStyle];
//    [formatter3 setDateStyle:NSDateFormatterShortStyle];
//    
//    NSString *detailstext = [formatter3 stringFromDate:newDate];
//    NSDate *othernewdate = [formatter3 dateFromString:detailstext];
//    
//    NSString *message = [@"15 minutes until " stringByAppendingString:detailstext];
//    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.timeZone = [NSTimeZone systemTimeZone];
//    notification.fireDate = othernewdate;
//    notification.alertBody = message;
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.hasAction = YES;
//    notification.alertAction = NSLocalizedString(@"View", @"View notification button");
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    //completionHandler(UIBackgroundFetchResultNewData);

}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {

    UILocalNotification *not = [[UILocalNotification alloc] init];
    not.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    not.timeZone = [NSTimeZone defaultTimeZone];
    
    not.alertBody = [NSString stringWithFormat:@"test B %@", [NSDate date]];
    not.alertAction = @"handleEventsForBackgroundURLSession";
    not.soundName = UILocalNotificationDefaultSoundName;
    
    // Schedule it with the app
    [[UIApplication sharedApplication] scheduleLocalNotification:not];
}

#pragma mark - Persistent Methods

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

//2
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

//3
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"wup.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],  NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],  NSInferMappingModelAutomaticallyOption, nil];
    
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
        
        /*Error for store creation should be handled in here*/
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end