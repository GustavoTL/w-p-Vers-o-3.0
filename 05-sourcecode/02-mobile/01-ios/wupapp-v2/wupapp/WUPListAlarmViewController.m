//
//  WUPListAlarmViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPListAlarmViewController.h"

@interface WUPListAlarmViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray* alarmsArray;



@property (strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation* location;

@end

@implementation WUPListAlarmViewController

Alarm* selectedAlarm;

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDatabaseConnection];
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Alarm Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI
{
    //Testing Google Places API
//    WUPGooglePlacesAPIService* googlePlacesAPIService = [[WUPGooglePlacesAPIService alloc] init];
//    [googlePlacesAPIService searchLocationsWithName:@"Shopping Villa Lobos" AndLocation:CLLocationCoordinate2DMake(-23.556153,-46.750559) success:^(NSArray *arrayLocationsFound) {
//        NSLog(@"%s DEU CERTO",__PRETTY_FUNCTION__);
//        for(WUPGooglePlacesAPISearchResult* result in arrayLocationsFound)
//        {
//            NSLog(@"%s formattedAddress: %@ latitude: %f longitude: %f distanceFromHere: %f",__PRETTY_FUNCTION__,result.formattedAddress, result.location.latitude, result.location.longitude, result.distanceFromHere);
//        }
//    } failure:^{
//        NSLog(@"%s DEU ERRADO",__PRETTY_FUNCTION__);
//    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Changing TabBar Appearance
    UITabBar *tabBar = self.tabBarController.tabBar;
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
    {
        // set it just for this instance
        [tabBar setBackgroundImage:[UIImage imageNamed:@"navbar_alarm_image"]];
    }
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    [self loadDataFromDatabase];
    //clean it
    selectedAlarm = nil;
    //Start looking for user's location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
        [self.locationManager respondsToSelector:requestSelector]) {
        ((void (*)(id, SEL))[self.locationManager methodForSelector:requestSelector])(self.locationManager, requestSelector);
        [self.locationManager startUpdatingLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    
    [self.locationManager startUpdatingLocation];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.locationManager stopUpdatingLocation];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(![self.alarmsArray count])
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"ListAlarmToAddEditSegue"]) {
        
        WUPAddAlarmViewController* vc = segue.destinationViewController;
        vc.selectedAlarm = selectedAlarm;
    }
}

-(void) loadDataFromDatabase
{
    self.alarmsArray = [[Alarm loadAll:self.managedObjectContext] mutableCopy];
    [self.tableView reloadData];
    
}

#pragma mark - Action methods

- (IBAction)addAlarm:(id)sender {
    [self performSegueWithIdentifier:@"ListAlarmToAddEditSegue" sender:self];
}

#pragma mark - UITableViewDelegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    long index = [indexPath row];
    static NSString *cellIdentifier = @"WUPListAlarmTableTableViewCell";
    Alarm *alarm = [self.alarmsArray objectAtIndex:index];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    WUPListAlarmTableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.alarm = alarm;
    cell.whenAlarmLabel.text = [dateFormatter stringFromDate:alarm.whenTime];
    if([alarm.repeatsFor isEqualToString:@""]){
        cell.destinationAndRepeatIntervalLabel.text = [NSString stringWithFormat:@"%@, %@",alarm.destination.name,@"Nunca"];
    }else{
        cell.destinationAndRepeatIntervalLabel.text = [NSString stringWithFormat:@"%@, %@",alarm.destination.name,[alarm.repeatsFor abreviateWeekdays]];
    }
    
    //Checking if Alarm repeatsFor is 0 and if its localnotification has been already fired. If so, we must deactivate it
    if([alarm.repeatsFor isEqualToString:@""] && ![self containsScheduledLocalNotificationsWithId:alarm.objectID]){
        alarm.actived =[NSNumber numberWithBool:NO];
        [self.managedObjectContext save:nil];
    }
    
    cell.onOffSwitch.on = [alarm.actived boolValue];
    cell.delegateChanges = self;
    
    if([cell.alarm.actived boolValue])
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.212 green:0.267 blue:0.31 alpha:1.0];
        
        cell.whenAlarmLabel.textColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.937 alpha:1.0];
        cell.destinationDescriptionLabel.textColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.937 alpha:1.0];
        cell.destinationAndRepeatIntervalLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.937 alpha:1.0];
        
        cell.whenAlarmLabel.textColor = [UIColor colorWithRed:0.647 green:0.647 blue:0.647 alpha:1.0];
        cell.destinationDescriptionLabel.textColor = [UIColor colorWithRed:0.647 green:0.647 blue:0.647 alpha:1.0];
        cell.destinationAndRepeatIntervalLabel.textColor = [UIColor colorWithRed:0.647 green:0.647 blue:0.647 alpha:1.0];
    }
    
    //Adding SWTableViewCell stuff
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.718 green:0.718 blue:0.796 alpha:1.0] title:@"Editar"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1 green:0.125 blue:0.125 alpha:1.0] title:@"Excluir"];
    cell.delegate = self;
    cell.rightUtilityButtons = rightUtilityButtons;
    return  cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.alarmsArray count];
}

#pragma mark - SWTableViewCell methods

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            Alarm* alarmItem = [self.alarmsArray objectAtIndex:[cellIndexPath row]];
            selectedAlarm = alarmItem;
            [self performSegueWithIdentifier:@"ListAlarmToAddEditSegue" sender:self];
            
            break;
        }case 1:
        {
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            Alarm* alarmItem = [self.alarmsArray objectAtIndex:[cellIndexPath row]];
            //Deleting related Local Notifications
            [self removeScheduledLocalNotificationsWithId:alarmItem.objectID];
            //Deleting from Database
            [self.managedObjectContext deleteObject:alarmItem];
            [self.managedObjectContext save:nil];
            //Deleting from array alarms
            [self.alarmsArray removeObjectAtIndex:cellIndexPath.row];
            //Deleting from table
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - WUPListAlarmTableTableViewCellDelegate methods

-(void)saveAlarmChanges:(Alarm *)alarm{
    [self.managedObjectContext save:nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = [alarm.actived boolValue] ? @"Calculando Trânsito" : @"Salvando";
    
    if([alarm.actived boolValue]){
        WUPNokiaTrafficConditionsService* trafficService = [[WUPNokiaTrafficConditionsService alloc]init];
        
        [trafficService calculateRouteTravelTimeUsing:self.location.coordinate AndDestination:CLLocationCoordinate2DMake([alarm.destination.latitude doubleValue],[alarm.destination.longitude doubleValue]) success:^(int ETATime,int distance) {
            [self successOnCalculateTrafficTimeWithAlarm:alarm AndETATime:ETATime];
        } failure:^{
            [self failureOnCalculateTrafficTimeWithAlarm:alarm];
        }];
    }else
    {
        //Only removing these alarm from local notifications
        [self commonOnCalculateTrafficTimeWithDate:nil AndAlarm:alarm];
    }
    
    
}

#pragma mark - Network callback methods

-(void) successOnCalculateTrafficTimeWithAlarm:(Alarm*) alarm AndETATime:(int) ETATime
{
    NSTimeInterval timeToLeave = [alarm.timeToLeave intValue];
    
#ifdef DEBUG
    NSLog(@"%s Date Before Traffic: %@",__PRETTY_FUNCTION__,alarm.whenTime);
#endif
    NSDate* date = [alarm.whenTime dateByAddingTimeInterval:(ETATime * -1)];
    date = [date dateByAddingTimeInterval:timeToLeave * -1];

#ifdef DEBUG
    NSLog(@"%s Date After Traffic: %@",__PRETTY_FUNCTION__,date);
#endif
    [self commonOnCalculateTrafficTimeWithDate:date AndAlarm:alarm];
}

-(void) failureOnCalculateTrafficTimeWithAlarm:(Alarm*) alarm
{
    [self commonOnCalculateTrafficTimeWithDate:alarm.whenTime AndAlarm:alarm];
}

-(void) commonOnCalculateTrafficTimeWithDate:(NSDate*) date AndAlarm:(Alarm*) alarm {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    if([alarm.actived boolValue]){
#ifdef DEBUG
        NSLog(@"%s Date After Reactivating Alarm: %@",__PRETTY_FUNCTION__,date);
#endif
        //Inserting new LocalNotification
//        [self insertNewWeeklyScheduledLocalNotificationWithDate:date AndRepeatInterval:alarm.repeatsFor AndSound:[NSString stringWithFormat:@"%@.%@",alarm.soundFilename,alarm.soundExtension] AndObjectID:alarm.objectID];
        
        [self insertNewWeeklyScheduledLocalNotificationWithDate:date AndRepeatInterval:alarm.repeatsFor AndSound:[NSString stringWithFormat:@"%@.%@",alarm.soundFilename,alarm.soundExtension] AndLabel:alarm.label AndTimeToLeave:[alarm.timeToLeave intValue] AndObjectID:alarm.objectID];
        
    }else{
#ifdef DEBUG
        NSLog(@"%s Date Before Desactivating Alarm: %@",__PRETTY_FUNCTION__,date);
#endif
        
        [self removeScheduledLocalNotificationsWithId:alarm.objectID];
    }
}

#pragma mark - CLLocationManagerDelegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
}

@end
