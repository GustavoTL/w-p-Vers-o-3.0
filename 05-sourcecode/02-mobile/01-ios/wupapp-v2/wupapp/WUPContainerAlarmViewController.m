//
//  WUPContainerAlarmViewController.m
//  wUpApp
//
//  Created by Adriano-Dcanm on 2/2/15.
//  Copyright (c) 2015 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPContainerAlarmViewController.h"


static NSString * const ChooseDayWeekViewControllerSegueIdentifier = @"ChooseDayWeekViewControllerSegueIdentifier";
static NSString * const CalendarViewControllerSegueIdentifier = @"CalendarViewControllerSegueIdentifier";

@interface WUPContainerAlarmViewController ()

@property (strong, nonatomic) NSString *currentSegueIdentifier;

@property (assign, nonatomic) BOOL transitionInProgress;

@end

@implementation WUPContainerAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    if ([self.search.advertisement.businessType isEqualToString:kAdvertisementBusinessTypeRent]) {
    self.currentSegueIdentifier = ChooseDayWeekViewControllerSegueIdentifier;
    //    }
    
    //    if ([self.search.advertisement.businessType isEqualToString:kAdvertisementBusinessTypeBuy]) {
    //        self.currentSegueIdentifier = BuySearchTableViewControllerSegueIdentifier;
    //    }
    
    //    if ([self.search.advertisement.businessType isEqualToString:kAdvertisementBusinessTypeSeason]) {
    //        self.currentSegueIdentifier = SeasonSearchTableViewControllerSegueIdentifier;
    //    }
    
    self.transitionInProgress = NO;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}



#pragma #############################################################################################################################
#pragma mark - Segue Navigation

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    NSLog(@"%i", self.childViewControllers.count);
//
//    if (([segue.identifier isEqualToString:RentSearchTableViewControllerSegueIdentifier]) && !self.rentSearchTVC) {
//        self.rentSearchTVC = segue.destinationViewController;
//        self.rentSearchTVC.search = self.search;
//    }
//
//    if (([segue.identifier isEqualToString:BuySearchTableViewControllerSegueIdentifier]) && !self.buySearchTVC) {
//        self.buySearchTVC = segue.destinationViewController;
//        self.buySearchTVC.search = self.search;
//    }
//
//    if (([segue.identifier isEqualToString:SeasonSearchTableViewControllerSegueIdentifier]) && !self.seasonSearchTVC) {
//        self.seasonSearchTVC = segue.destinationViewController;
//        self.seasonSearchTVC.search = self.search;
//    }
//
//    [self addChildViewController:segue.destinationViewController];
//    UIView *destinationView = ((UIViewController *)segue.destinationViewController).view;
//    destinationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    destinationView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    [self.view addSubview:destinationView];
//    [segue.destinationViewController didMoveToParentViewController:self];
//
//    NSLog(@"%i", self.childViewControllers.count);
//
//    if ([segue.identifier isEqualToString:RentSearchTableViewControllerSegueIdentifier]) {
//        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.rentSearchTVC];
//    }
//
//    if ([segue.identifier isEqualToString:BuySearchTableViewControllerSegueIdentifier]) {
//        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.buySearchTVC];
//    }
//
//    if ([segue.identifier isEqualToString:SeasonSearchTableViewControllerSegueIdentifier]) {
//        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.seasonSearchTVC];
//    }
//}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (([segue.identifier isEqualToString:ChooseDayWeekViewControllerSegueIdentifier]) && !self.choseWeekdaysTVC) {
                
        self.choseWeekdaysTVC = segue.destinationViewController;
        self.choseWeekdaysTVC.alreadySelectedDaysOfWeek = self.alreadySelectedDaysOfWeek;        
    }
    
    if (([segue.identifier isEqualToString:CalendarViewControllerSegueIdentifier]) && !self.addAlarmCalendarTVC) {
        
        self.addAlarmCalendarTVC = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:ChooseDayWeekViewControllerSegueIdentifier]) {
        
        if (self.childViewControllers.count > 0) {
        
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.choseWeekdaysTVC];

        } else {
            
            [self addChildViewController:segue.destinationViewController];
            UIView *destinationView = ((UIViewController *)segue.destinationViewController).view;
            destinationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            destinationView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:destinationView];
            [segue.destinationViewController didMoveToParentViewController:self];
        }
   
    } else if ([segue.identifier isEqualToString:CalendarViewControllerSegueIdentifier]) {
        
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.addAlarmCalendarTVC];
    
    }
}

#pragma #############################################################################################################################
#pragma mark - Private Methods

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
      
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL finished) {
        
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        self.transitionInProgress = NO;
    
    }];
}

#pragma #############################################################################################################################
#pragma mark - Public Methods

- (void)viewControllersDidSwapWithSelectedIndex:(NSInteger)selectedIndex {
    if (self.transitionInProgress) {
        return;
    }
    
    self.transitionInProgress = YES;
    
    if (selectedIndex == 0) {
        self.currentSegueIdentifier = ChooseDayWeekViewControllerSegueIdentifier;
    }
    
    if (selectedIndex == 1) {
        self.currentSegueIdentifier = CalendarViewControllerSegueIdentifier;
    }
    
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

- (NSArray*)repeatDays {

    return self.choseWeekdaysTVC.arraySelectedDaysOfWeek;

}

- (NSDate*) calendarDaySelected {
    
    return self.addAlarmCalendarTVC.dateCalendarSelected;
}

@end
