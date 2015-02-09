//
//  WUPAddAlarmViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPAddAlarmViewController.h"
#import "WUPAddAlarmeContainerViewController.h"

@interface WUPAddAlarmViewController ()

@property(strong,nonatomic) WUPSong* selectedSong;
@property(strong,nonatomic) NSArray* selectedRepeatDays;
@property(strong,nonatomic) Destination* selectedDestination;
@property(strong,nonatomic) NSString* selectedLabel;
@property(nonatomic) int selectedTimeToLeave;
@property(strong,nonatomic) CLLocation* location;

@property(strong,nonatomic) NSDate *dateSelected;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarTittle;
@property (weak, nonatomic) IBOutlet UILabel *descriptiveFirstLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptiveSecondeLineLabel;

@property (weak, nonatomic) IBOutlet UILabel *alarmLabelLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmDestinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmRepeatsForLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmSoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmTimeToLeaveLabel;

@property (weak, nonatomic) IBOutlet UILabel *alarmLabelContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmDestinationContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmRepeatsForContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmSoundContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmTimeToLeaveContentLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPicker;

@property (strong,nonatomic) CLLocationManager *locationManager;
@end

@implementation WUPAddAlarmViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDatabaseConnection];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Add/Edit Alarm Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

    if(self.selectedAlarm){
        self.navigationBarTittle.title = @"Editar";
        self.selectedSong = [[WUPSong alloc] initWithName:self.selectedAlarm.soundName
                                              AndFileName:self.selectedAlarm.soundFilename
                                             AndExtension:self.selectedAlarm.soundExtension];
        
        if(![self.selectedAlarm.repeatsFor isEqualToString:@""]) {
            
            self.selectedRepeatDays = [self.selectedAlarm.repeatsFor componentsSeparatedByString:@", "];
        
        } else {
        
            self.selectedRepeatDays = [[NSArray alloc]init];
        }
        
        self.dateSelected = self.selectedAlarm.dateSelected;
        self.selectedDestination = self.selectedAlarm.destination;
        self.selectedLabel = self.selectedAlarm.label;
        self.selectedTimeToLeave = [self.selectedAlarm.timeToLeave intValue];
        
       
        self.dataPicker.date = self.selectedAlarm.whenTime;
        
    } else {
        
        self.navigationBarTittle.title = @"Adicionar";
        self.selectedSong = [WUPConstants DEFAULT_SONG];
        self.selectedRepeatDays =[WUPConstants DEFAULT_REPEATDAYS];
        self.selectedDestination =  nil;
        self.selectedTimeToLeave = 60*15;
        self.selectedLabel = @"Alarme";
        self.dateSelected = NULL;
    }
    
    
    [self setupUI];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self listScheduledMasterLocalNotifications];
    
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

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"AddEditSegueToPickSong"]) {
        
        WUPChoseSongViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.alreadySelectedSong = self.selectedSong;
    
    } else if([segue.identifier isEqualToString:@"AddEditSegueToPickWeekdays"]){
        
        WUPAddAlarmeContainerViewController *vc = segue.destinationViewController;
        vc.alreadySelectedDaysOfWeek = [self.selectedRepeatDays mutableCopy];
        vc.delegate = self;
        
        //WUPChoseWeekdaysViewController *vc = segue.destinationViewController;
        //vc.delegate = self;
        //vc.alreadySelectedDaysOfWeek = [self.selectedRepeatDays mutableCopy];
    
    } else if([segue.identifier isEqualToString:@"AddEditSegueToPickDestination"]){
        
        WUPListDestinationViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.alreadySelectedDesination = self.selectedDestination;
    
    } else if([segue.identifier isEqualToString:@"AddEditSegueToPickLabel"]){
        
        WUPChoseAlarmLabelViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.alreadySelectedLabel = self.selectedLabel;
    
    } else if([segue.identifier isEqualToString:@"AddEditSegueToTimeToLeave"]){
        
        WUPSetTimeToLeaveViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.alreadySelectedTimeToLeave = self.selectedTimeToLeave;
    }
}

#pragma mark - UI Methods

- (void)updateRepeateDaysLabel {
    
    self.alarmRepeatsForLabel.text = NSLocalizedString(@"repetir", nil);
    
    NSString* selectedDaysLabelContent = @"";
    if([self.selectedRepeatDays count]) {
        
        for(int i =0; i < [self.selectedRepeatDays count];i++) {
            selectedDaysLabelContent = [selectedDaysLabelContent stringByAppendingString:[[((NSString*)[self.selectedRepeatDays objectAtIndex:i]) capitalizedString] substringWithRange:NSMakeRange(0, 3)]];
            if(i != [self.selectedRepeatDays count] - 1){
                selectedDaysLabelContent = [selectedDaysLabelContent stringByAppendingString:@", "];
            }
        }
    
    } else {
        
        selectedDaysLabelContent = @"Nunca";
    }
    
    self.alarmRepeatsForContentLabel.text = selectedDaysLabelContent;
}

- (void)updateSelectDayLabel {
    
    self.alarmRepeatsForLabel.text = NSLocalizedString(@"dia", nil);
    
    NSDateFormatter *localFormatter = [[NSDateFormatter alloc] init];
    [localFormatter setDateFormat:@"yyyy/MM/dd/ HH:mm:ss a"];
    [localFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSString *formattedDatePicker = [localFormatter stringFromDate:self.dataPicker.date];
    
    NSArray *arrDate = [[[formattedDatePicker componentsSeparatedByString:@" "] objectAtIndex:1]componentsSeparatedByString:@":"];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.dateSelected];
    [components setHour:[[arrDate objectAtIndex:0] integerValue]];
    [components setMinute:[[arrDate objectAtIndex:1] integerValue]];
    
    [cal setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDate *date = [cal dateFromComponents:components];

    [localFormatter setDateFormat:@"dd/MM/yyyy"];
    
    self.alarmRepeatsForContentLabel.text = [localFormatter stringFromDate:date];

}

- (void)updateTimeToLiveContentLabel:(int)seconds
{
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    
    if(hour == 0)
    {
        self.alarmTimeToLeaveContentLabel.text = [NSString stringWithFormat:@"%dm",mins];
    }
    else
    {
        self.alarmTimeToLeaveContentLabel.text = [NSString stringWithFormat:@"%dh %dm",hour,mins];
    }
}

-(void) setupUI {
    
    self.alarmSoundContentLabel.text = self.selectedSong.name;
    
    if(self.dateSelected) {
    
        [self updateSelectDayLabel];
        
    } else {
    
        [self updateRepeateDaysLabel];
    }
    
    if(self.selectedDestination){
        self.alarmDestinationContentLabel.text = self.selectedDestination.name;
    }
    
    self.alarmLabelContentLabel.text = self.selectedLabel;
    [self updateTimeToLiveContentLabel:self.selectedTimeToLeave];
    
    //Changing Fonts
    self.descriptiveFirstLineLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.descriptiveSecondeLineLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.alarmLabelLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:16.0f];
    self.alarmDestinationLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:16.0f];
    self.alarmRepeatsForLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:16.0f];
    self.alarmSoundLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:16.0f];
    self.alarmTimeToLeaveLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:16.0f];
    
    self.alarmLabelContentLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.alarmDestinationContentLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.alarmRepeatsForContentLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.alarmSoundContentLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.alarmTimeToLeaveContentLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    
}

#pragma mark - WUPChoseRepeatViewControllerDelegate methods
-(void) pickedRepeatDays:(NSArray*) selectedDaysOfWeek {

    if([selectedDaysOfWeek count]){
        
        NSLog(@"%s we got these days %@",__PRETTY_FUNCTION__,selectedDaysOfWeek);
        
    } else {
        
        NSLog(@"%s we got no selected days",__PRETTY_FUNCTION__);
    }
    
    self.selectedRepeatDays = selectedDaysOfWeek;
    self.dateSelected = NULL;
    [self updateRepeateDaysLabel];
}

-(void) pickedCalendarDay:(NSDate*) selectedDate {

    self.dateSelected = selectedDate;
    self.selectedRepeatDays = [NSArray array];
    [self updateSelectDayLabel];
    
    //NSLog(@"%s pickedCalendarDay %@",__PRETTY_FUNCTION__, selectedDate);
}

#pragma mark - WUPChoseSongViewControllerDelegate methods

-(void)pickedASong:(WUPSong *)song {
    
    if(song) {
    
        NSLog(@"%s we got a song %@",__PRETTY_FUNCTION__,song.name);
        self.selectedSong = song;
        self.alarmSoundContentLabel.text = self.selectedSong.name;
    
    } else {
        
        NSLog(@"%s we haven't got a song",__PRETTY_FUNCTION__);
    }
}

//-(void)pickedRepeatDays:(NSArray *)selectedDaysOfWeek{
//    
//    if([selectedDaysOfWeek count]){
//        
//        NSLog(@"%s we got these days %@",__PRETTY_FUNCTION__,selectedDaysOfWeek);
//    
//    } else {
//        
//        NSLog(@"%s we got no selected days",__PRETTY_FUNCTION__);
//    }
//    
//    self.selectedRepeatDays = selectedDaysOfWeek;
//    [self updateRepeateDaysLabel];
//}

-(void)pickedADestination:(Destination *)destination{
    
    if(destination){
        
        NSLog(@"%s we got that destination %@",__PRETTY_FUNCTION__,destination.name);
        self.selectedDestination = destination;
        self.alarmDestinationContentLabel.text = destination.name;
    
    } else {
        NSLog(@"%s we got no destinations",__PRETTY_FUNCTION__);
    }
}

-(void)pickedALabel:(NSString *)label
{
    if(label) {
        
        NSLog(@"%s we got that label %@",__PRETTY_FUNCTION__,label);
        self.selectedLabel = label;
        self.alarmLabelContentLabel.text = label;
    
    } else {
        
        NSLog(@"%s we got no labels",__PRETTY_FUNCTION__);
    }
}

-(void)pickedATimeToleave:(int)seconds
{
    NSLog(@"%s we got that time to leave %d",__PRETTY_FUNCTION__,seconds);
    self.selectedTimeToLeave = seconds;
    
    [self updateTimeToLiveContentLabel:seconds];
}

//HEADER_SEARCH_PATHS = $(SDKROOT)/usr/include/libxml2

#pragma mark - Actions methods
- (IBAction)touchUpNavBarSaveButton:(id)sender {
    
    if(self.selectedDestination && self.selectedSong && ![self.selectedLabel isEqualToString:@""]) {
    
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Salvando";
        
        BOOL editing = NO;
        
        Alarm* alarm;
        if(self.selectedAlarm){
            
            alarm = self.selectedAlarm;
            editing = YES;
        
        } else {
            
            alarm = [Alarm insertNewObjectInContext:self.managedObjectContext];
        }
        
        alarm.whenTime = self.dataPicker.date;
        alarm.dateSelected = self.dateSelected;
        alarm.destination = self.selectedDestination;
        alarm.soundName = self.selectedSong.name;
        alarm.soundFilename = self.selectedSong.fileName;
        alarm.soundExtension = self.selectedSong.extension;
        alarm.label = self.selectedLabel;
        alarm.timeToLeave = [NSNumber numberWithInt:self.selectedTimeToLeave];
        
        NSString* selectedDaysLabelContent = @"";
        
        if([self.selectedRepeatDays count]) {
            
            for(int i =0; i < [self.selectedRepeatDays count];i++) {
                
                selectedDaysLabelContent = [selectedDaysLabelContent stringByAppendingString:((NSString*)[self.selectedRepeatDays objectAtIndex:i])];
                
                if(i != [self.selectedRepeatDays count] - 1) {
                    
                    selectedDaysLabelContent = [selectedDaysLabelContent stringByAppendingString:@", "];
                }
            }
            
            alarm.repeatsFor = selectedDaysLabelContent;
        
        } else {
        
            alarm.repeatsFor = @"";
        
        }
        
        alarm.actived = [NSNumber numberWithBool:YES];
        alarm.label = self.selectedLabel;
        alarm.timeToLeave = [NSNumber numberWithInt:self.selectedTimeToLeave];
        
        [self.managedObjectContext save:nil];
        
        if(editing) {
            
            [self removeScheduledLocalNotificationsWithId:alarm.objectID];
        }
        
        WUPNokiaTrafficConditionsService* trafficService = [[WUPNokiaTrafficConditionsService alloc]init];
        
        [trafficService calculateRouteTravelTimeUsing:self.location.coordinate
                                       AndDestination:CLLocationCoordinate2DMake([alarm.destination.latitude doubleValue],
                                                                                 [alarm.destination.longitude doubleValue])
                                              success:^(int ETATime,int distance) {
                                                  
            [self successOnCalculateTrafficTimeWithAlarm:alarm AndETATime:ETATime];
        
                                              } failure:^{
                                                  
            [self failureOnCalculateTrafficTimeWithAlarm:alarm];
        
                                              }];
        
        
    } else {
        
        UIAlertView *view = [WUPAlertBuilderUtils buildAlertForMissingInformation];
        [view show];
    }
}

- (IBAction)touchUpNavBarCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)touchUpChooseDestinationView:(id)sender {
    [self performSegueWithIdentifier:@"AddEditSegueToPickDestination" sender:self];
}
- (IBAction)touchUpChooseWeekdays:(id)sender {
    [self performSegueWithIdentifier:@"AddEditSegueToPickWeekdays" sender:self];
}
- (IBAction)touchUpChooseSongView:(id)sender {
    [self performSegueWithIdentifier:@"AddEditSegueToPickSong" sender:self];
}
- (IBAction)touchUpChooseLabelView:(id)sender {
    [self performSegueWithIdentifier:@"AddEditSegueToPickLabel" sender:self];
}
- (IBAction)touchUpTimeToLeaveView:(id)sender {
    [self performSegueWithIdentifier:@"AddEditSegueToTimeToLeave" sender:self];
}

#pragma mark - Network callback methods

-(void) successOnCalculateTrafficTimeWithAlarm:(Alarm*) alarm AndETATime:(int) ETATime {
    
    NSTimeInterval timeToLeave = [alarm.timeToLeave intValue];

#ifdef DEBUG
    NSLog(@"%s Date Before Traffic: %@",__PRETTY_FUNCTION__,self.dataPicker.date);
#endif
    
    NSDate* date = [self.dataPicker.date dateByAddingTimeInterval:(ETATime * -1)];
    
    if(alarm.dateSelected != NULL) {
        
        NSDateFormatter *localFormatter = [[NSDateFormatter alloc] init];
        [localFormatter setDateFormat:@"yyyy/MM/dd/ HH:mm:ss a"];
        [localFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSString *formattedDatePicker = [localFormatter stringFromDate:self.dataPicker.date];
        
        NSArray *arrDate = [[[formattedDatePicker componentsSeparatedByString:@" "] objectAtIndex:1]componentsSeparatedByString:@":"];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:alarm.dateSelected];
        [components setHour:[[arrDate objectAtIndex:0] integerValue]];
        [components setMinute:[[arrDate objectAtIndex:1] integerValue]];
        
        [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        date = [cal dateFromComponents:components];
        
    } else {
    
        date = self.dataPicker.date;
    }
    
    //NSDate* date = [self.dataPicker.date dateByAddingTimeInterval:(ETATime * -1)];
    //date = [date dateByAddingTimeInterval:timeToLeave * -1];
    
    date = [date dateByAddingTimeInterval:(ETATime * -1)];
    date = [date dateByAddingTimeInterval:timeToLeave * -1];
    
#ifdef DEBUG
    NSLog(@"%s Date After Traffic: %@",__PRETTY_FUNCTION__,date);
#endif
    
    [self commonOnCalculateTrafficTimeWithDate:date AndAlarm:alarm];
}

-(void) failureOnCalculateTrafficTimeWithAlarm:(Alarm*) alarm {
    
    [self commonOnCalculateTrafficTimeWithDate:self.dataPicker.date AndAlarm:alarm];
}

-(void) commonOnCalculateTrafficTimeWithDate:(NSDate*) date AndAlarm:(Alarm*) alarm {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    //Inserting new LocalNotification
    [self insertNewWeeklyScheduledLocalNotificationWithDate:date
                                          AndRepeatInterval:alarm.repeatsFor
                                                   AndSound:[NSString stringWithFormat:@"%@.%@",alarm.soundFilename,alarm.soundExtension]
                                                   AndLabel:alarm.label
                                             AndTimeToLeave:[alarm.timeToLeave intValue]
                                                AndObjectID:alarm.objectID];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
}



@end
