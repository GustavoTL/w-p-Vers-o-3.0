//
//  WUPSetTimeToLeaveViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPSetTimeToLeaveViewController.h"

@interface WUPSetTimeToLeaveViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptiveFirstLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptiveSecondeLineLabel;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation WUPSetTimeToLeaveViewController
#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Time to Leave Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI
{
    //Changing Fonts
    self.descriptiveFirstLineLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.descriptiveSecondeLineLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    
    int seconds = self.alreadySelectedTimeToLeave;
    int hour = seconds / 3600;
    int mins = (seconds % 3600) / 60;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger preservedComponentsFullDate = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit);
    NSUInteger preservedComponentsTruncatedDate = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    
    NSDateComponents *difference = [calendar components:preservedComponentsFullDate
                                               fromDate:self.datePicker.date];
    difference.hour = hour;
    difference.minute = mins;
    
    [self.datePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
    [self.datePicker setCountDownDuration:seconds];
    
    
    self.datePicker.date = [calendar dateByAddingComponents:difference
                                                     toDate:[calendar dateFromComponents:[calendar components:preservedComponentsTruncatedDate fromDate:[NSDate date]]] options:0];
}

#pragma mark - Actions methods
- (IBAction)touchUpNavBarCancelButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchUpNavBarOkButton:(id)sender {
    
    NSDateComponents *time = [[NSCalendar currentCalendar]
                              components:NSHourCalendarUnit | NSMinuteCalendarUnit
                              fromDate:self.datePicker.date];
    NSInteger secondsFromPicker = ([time hour] * 60 * 60) + ([time minute] * 60);
    self.alreadySelectedTimeToLeave = (int)secondsFromPicker;
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.delegate)
        {
            [self.delegate pickedATimeToleave:self.alreadySelectedTimeToLeave];
        }
    }];
}


@end
