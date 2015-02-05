//
//  WUPHomeViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPHomeViewController.h"

@interface WUPHomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *instructionsButton;
@property (weak, nonatomic) IBOutlet UILabel *nowLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLongLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereToGoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToGoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToGoDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timeToGoImage;
@property (weak, nonatomic) IBOutlet UIView *nextAlarmContainerView;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

@property (strong, nonatomic) UILocalNotification *nextLocationNotification;

@property (strong, nonatomic) NSTimer* timerNowClock;
@property (strong, nonatomic) NSTimer* timerTimeToGoClock;

@property (strong, nonatomic) NSDateFormatter* dateFormatterNowClock;
@property (strong, nonatomic) NSDateFormatter* dateFormatterNowLongFormatClock;
@property (strong, nonatomic) NSDateFormatter* dateFormatterNowWeekdayFormatClock;

@property (strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation* location;

@end

@implementation WUPHomeViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDatabaseConnection];
    
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI
{
    self.dateFormatterNowClock = [[NSDateFormatter alloc] init];
    [self.dateFormatterNowClock setDateFormat:@"HH:mm"]; //24hr time format
    
    self.dateFormatterNowLongFormatClock = [[NSDateFormatter alloc] init];
    [self.dateFormatterNowLongFormatClock setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [self.dateFormatterNowLongFormatClock setDateFormat:@"dd MMM yyyy"];
    
    self.dateFormatterNowWeekdayFormatClock = [[NSDateFormatter alloc] init];
    [self.dateFormatterNowWeekdayFormatClock setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"]];
    [self.dateFormatterNowWeekdayFormatClock setDateFormat:@"EEEE"];
    
    //Applying Fonts
    self.nowLabel.font = [UIFont fontWithName:kPlutoFontNameThin size:80.0f];
    self.dateLongLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:15.0f];
    self.whereToGoLabel.font = [UIFont fontWithName:kProximaNovaFontNameLight size:20.0f];
    self.timeToGoDescriptionLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:10.0f];
    self.timeToGoLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:20.0f];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Changing TabBar Appearance
    UITabBar *tabBar = self.tabBarController.tabBar;
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
    {
        // set it just for this instance
        [tabBar setBackgroundImage:[UIImage imageNamed:@"navbar_home_image"]];
    }
    
    [self cleanIconBadgeNumber];
    
    [self listScheduledMasterLocalNotifications];

    [self updateNextLocalNotification];
    [self updateNowClock];
    [self updateTimeToGoUI];
    self.timerNowClock = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateNowClock) userInfo:nil repeats:YES];
    self.timerTimeToGoClock = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeToGoUI) userInfo:nil repeats:YES];
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Checking if it's the first time I'm opening this app
    if (![[NSUserDefaults standardUserDefaults] boolForKey:[WUPConstants PREF_SETTING_FIRSTTIMELAUNCH]])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[WUPConstants PREF_SETTING_FIRSTTIMELAUNCH]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self playMovie];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timerNowClock invalidate];
    [self.timerTimeToGoClock invalidate];
    
}

#pragma mark - Actions methods

-(void) updateNowClock
{
    NSDate* date = [NSDate date];
    self.nowLabel.text = [self.dateFormatterNowClock stringFromDate:date];
    self.dateLongLabel.text = [NSString stringWithFormat:@"%@ - %@",[self.dateFormatterNowLongFormatClock stringFromDate:date],[[self.dateFormatterNowWeekdayFormatClock stringFromDate:date] capitalizedString]];
}

-(void) updateTimeToGoUI {
    
    NSDate* date = [NSDate date];
    
    [self updateNextLocalNotification];
    
    if(self.nextLocationNotification)
    {
        self.timeToGoImage.hidden = NO;
        self.timeToGoLabel.hidden = NO;
        self.timeToGoDescriptionLabel.hidden = NO;
        self.nextAlarmContainerView.hidden = NO;
        
        NSDate* nextFireDate = [self.nextLocationNotification nextFireDateAfterDate:date];
        
//        NSLog(@"%s nextFireDate:%@",__PRETTY_FUNCTION__,nextFireDate);
        
        NSTimeInterval intervalNextFireDate = [nextFireDate timeIntervalSinceDate:date];
        long seconds = lroundf(intervalNextFireDate) ;
        
//      NSLog(@"%s seconds: %lu intervalNextFireDate: %lu  timeToLeave: %lu",__PRETTY_FUNCTION__,seconds,lroundf(intervalNextFireDate),lroundf(timeToLeave));
        
        int hour = (int)seconds / 3600;
        
        int days = (int)hour / 24;
        
        int mins = (seconds % 3600) / 60;
        int secs = seconds % 60;
        
//        if(days > 0) {
//            
//            self.timeToGoLabel.text = [NSString stringWithFormat:@"%dd %dh %dm",days, hour - (days * 24),mins];
//        
//        } else
        
        if(hour == 0) {
            
            self.timeToGoLabel.text = [NSString stringWithFormat:@"%dm %ds",mins,secs];
        
        } else {
            
            self.timeToGoLabel.text = [NSString stringWithFormat:@"%dh %dm %ds",hour,mins,secs];
        }
        
        Alarm  *alarm = [self alarmFromNotificationUserInfo:self.nextLocationNotification.userInfo];
        self.whereToGoLabel.text = [NSString stringWithFormat:@"%@:",[alarm.destination.name uppercaseString]];
        
    } else {
        
        self.timeToGoImage.hidden = YES;
        self.timeToGoLabel.hidden = YES;
        self.timeToGoDescriptionLabel.hidden = YES;
        self.nextAlarmContainerView.hidden = YES;
    }
}

-(void) updateNextLocalNotification
{
    NSDate* date = [NSDate date];
//    NSLog(@"%s dateUTC: %@",__PRETTY_FUNCTION__,[WUPDateUtils convertDateInUTCString:date]);
    
    //Checking LocalNotifications
    NSArray* arrayNotifications = [self scheduledTimeToLeaveLocalNotifications];
    
    if([arrayNotifications count]) {
        
        NSArray *sorted = [arrayNotifications sortedArrayUsingComparator:^NSComparisonResult(UILocalNotification *obj1, UILocalNotification *obj2) {
            NSDate *next1 = [obj1 nextFireDateAfterDate:date];
            NSDate *next2 = [obj2 nextFireDateAfterDate:date];
//            NSLog(@"%s next1: %@ next2: %@",__PRETTY_FUNCTION__,next1,next2);
            return [next1 compare:next2];
        }];
        
        self.nextLocationNotification = [sorted firstObject];
        
//        NSLog(@"%s self.nextLocationNotification.nextFireDate:%@",__PRETTY_FUNCTION__,[self.nextLocationNotification nextFireDateAfterDate:date]);
    
    } else {
        
        self.nextLocationNotification = nil;
    }
}

-(void) updateTrafficToNextLocationNotification
{
    if(self.nextLocationNotification)
    {
        NSDictionary* userInfoDict = self.nextLocationNotification.userInfo;
        Alarm  *alarm = [self alarmFromNotificationUserInfo:userInfoDict];
        
        WUPNokiaTrafficConditionsService* trafficService = [[WUPNokiaTrafficConditionsService alloc]init];
        
        [trafficService calculateRouteTravelTimeUsing:self.location.coordinate AndDestination:CLLocationCoordinate2DMake([alarm.destination.latitude doubleValue],[alarm.destination.longitude doubleValue]) success:^(int ETATime,int distancewwww) {
            [self successOnCalculateTrafficTimeWithAlarm:alarm AndETATime:ETATime];
        } failure:^{
            [self failureOnCalculateTrafficTimeWithAlarm:alarm];
        }];
    }
}

-(void)playMovie
{
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"wup_final" withExtension:@"m4v"];
    _moviePlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer setFullscreen:YES animated:YES];
}

#pragma mark - Network callback methods

-(void) successOnCalculateTrafficTimeWithAlarm:(Alarm*) alarm AndETATime:(int) ETATime
{
    NSTimeInterval timeToLeave = [alarm.timeToLeave intValue];
    
    NSLog(@"%s Date Before Traffic: %@",__PRETTY_FUNCTION__,alarm.whenTime);
    NSDate* date = [alarm.whenTime dateByAddingTimeInterval:(ETATime * -1)];
     date = [date dateByAddingTimeInterval:timeToLeave * -1];
    
    NSLog(@"%s Date After Traffic: %@",__PRETTY_FUNCTION__,date);
    [self commonOnCalculateTrafficTimeWithDate:date AndAlarm:alarm];
}

-(void) failureOnCalculateTrafficTimeWithAlarm:(Alarm*) alarm
{
    [self commonOnCalculateTrafficTimeWithDate:alarm.whenTime AndAlarm:alarm];
}

-(void) commonOnCalculateTrafficTimeWithDate:(NSDate*) date AndAlarm:(Alarm*) alarm {
//    NSLog(@"%s date: %@",__PRETTY_FUNCTION__,date);
    
    // Only try to replace alarm if this alarm isn't set for never repeating
    if(![alarm.repeatsFor isEqualToString:@""]){
    
        [self removeScheduledLocalNotificationsWithId:alarm.objectID];

        //Inserting new LocalNotification
        [self insertNewWeeklyScheduledLocalNotificationWithDate:date AndRepeatInterval:alarm.repeatsFor AndSound:[NSString stringWithFormat:@"%@.%@",alarm.soundFilename,alarm.soundExtension] AndLabel:alarm.label AndTimeToLeave:[alarm.timeToLeave intValue] AndObjectID:alarm.objectID];
    }
}

#pragma mark - CLLocationManagerDelegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    [self updateTrafficToNextLocationNotification];
}

#pragma mark - MediaPlayer callback methods

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}

@end
