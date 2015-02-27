//
//  WUPAddAlarmeContainerViewController.m
//  wUpApp
//
//  Created by Adriano-Dcanm on 2/2/15.
//  Copyright (c) 2015 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPAddAlarmeContainerViewController.h"
#import "WUPContainerAlarmViewController.h"

static NSString * const ContainerAlarmViewControllerSegueIdentifier = @"ContainerAlarmViewControllerSegueIdentifier";

typedef NS_ENUM(NSInteger, TransactionType) {
    Daily = 0,
    Calendar = 1
};

@interface WUPAddAlarmeContainerViewController ()

@property (nonatomic, strong) NSString *currentSegueIdentifier;
@property (nonatomic, assign) BOOL transitionInProgress;
@property (nonatomic, strong) WUPContainerAlarmViewController *containerViewController;

@property (nonatomic, assign) TransactionType TransactionTypeEnum;

@end

@implementation WUPAddAlarmeContainerViewController

- (IBAction)transactionDidChange:(UISegmentedControl *)sender {
    
    self.TransactionTypeEnum = sender.selectedSegmentIndex;
    
    [self.containerViewController viewControllersDidSwapWithSelectedIndex:sender.selectedSegmentIndex];

}

- (IBAction)touchUpNavBack:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchUpNavSave:(id)sender {
    
    switch (self.TransactionTypeEnum) {

        case Daily:
            
            break;
            
        case Calendar:
            
            if([self.containerViewController.addAlarmCalendarTVC dateCalendarSelected] == NULL) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atenção"
                                                               message:@"Você deve escolher uma data"
                                                              delegate:nil
                                                     cancelButtonTitle:@"ok"
                                                     otherButtonTitles:nil, nil];
                
                [alert show];
                
                return;
            }
            
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        switch (self.TransactionTypeEnum) {
            case Daily:
                
                [self.delegate pickedRepeatDays:[self.containerViewController repeatDays]];
                
                break;
            case Calendar:
                
                [self.delegate pickedCalendarDay:[self.containerViewController.addAlarmCalendarTVC dateCalendarSelected]];
                
                break;
            default:
                break;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.TransactionTypeEnum = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:ContainerAlarmViewControllerSegueIdentifier]) {
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.alreadySelectedDaysOfWeek = self.alreadySelectedDaysOfWeek;
        
    }
}

@end
