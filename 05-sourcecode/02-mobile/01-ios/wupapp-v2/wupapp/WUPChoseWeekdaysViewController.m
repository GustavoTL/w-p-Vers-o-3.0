//
//  WUPChoseWeekdaysViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPChoseWeekdaysViewController.h"

@interface WUPChoseWeekdaysViewController ()

@property(strong,nonatomic) NSArray* arrayDaysOfWeek;


@end

@implementation WUPChoseWeekdaysViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Choose Weekday Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI{
    
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:language]];
    self.arrayDaysOfWeek = [dateFormatter weekdaySymbols];
    self.arraySelectedDaysOfWeek = [[NSMutableArray alloc] initWithCapacity:7];
}


#pragma mark - Actions methods

//- (IBAction)touchUpNavBarCancelButton:(id)sender {
//    
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (IBAction)touchUpNavOkButton:(id)sender {
//    
//    [self dismissViewControllerAnimated:YES completion:^(){
//        if(self.delegate){
//            [self.delegate pickedRepeatDays:self.arraySelectedDaysOfWeek];
//        }
//    }];
//}

#pragma mark - UITableViewDelegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayDaysOfWeek count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"WUPChoseWeekdaysTableViewCell";
    long index = [indexPath row];
    
    WUPChoseWeekdaysTableViewCell* cell  = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSString* day = [[self.arrayDaysOfWeek objectAtIndex:index] capitalizedString];
    NSString* each = @"";
    if([day hasSuffix:@"a"]){
        each = NSLocalizedString(@"toda", nil);
    }else{
        each = NSLocalizedString(@"todo", nil);
    }
    cell.dayOfWeeekLabel.text = [NSString stringWithFormat:@"%@ %@",each,day];
    
    //Check if we must check that cell
    if([self.alreadySelectedDaysOfWeek count]){
        if ([self.alreadySelectedDaysOfWeek indexOfObject:[self.arrayDaysOfWeek objectAtIndex:index]] != NSNotFound){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.checkedIndexPath = YES;
            [self.alreadySelectedDaysOfWeek removeObjectAtIndex:[self.alreadySelectedDaysOfWeek indexOfObject:[self.arrayDaysOfWeek objectAtIndex:index]]];
            [self.arraySelectedDaysOfWeek addObject:[self.arrayDaysOfWeek objectAtIndex:index]];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* day = [self.arrayDaysOfWeek objectAtIndex:[indexPath row]];
    
    WUPChoseWeekdaysTableViewCell* cell  = (WUPChoseWeekdaysTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.checkedIndexPath)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.checkedIndexPath = NO;
        [self.arraySelectedDaysOfWeek removeObjectIdenticalTo:day];
    
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.checkedIndexPath = YES;
        [self.arraySelectedDaysOfWeek addObject:day];
    }
    
    [tableView reloadData];
}


@end
