//
//  WUPListDestinationViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPListDestinationViewController.h"

@interface WUPListDestinationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray* destinationsArray;

@end

@implementation WUPListDestinationViewController

long selectedRow;

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDatabaseConnection];
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Choose Destination Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI {
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self loadDataFromDatabase];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ListDestinationToSubscribeDestinationSegue"]) {
        
        WUPAddDestinationViewController* vc = segue.destinationViewController;
        if(sender == self){ // It's an edit opertation otherwise it's an add operation
            vc.selectedDestination = self.alreadySelectedDesination;
        }
    }
}

-(void) loadDataFromDatabase {
    
    self.destinationsArray = [[Destination loadAll:self.managedObjectContext] mutableCopy];
    //Searching for alreadySelectedDesination index on array
    selectedRow = [self.destinationsArray indexOfObject:self.alreadySelectedDesination];
    [self.tableView reloadData];
    
}

#pragma mark - UITableViewDelegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.destinationsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    long index = [indexPath row];
    static NSString* identifier = @"WUPListDestinationTableViewCell";
    Destination *destination = [self.destinationsArray objectAtIndex:index];
    
    WUPListDestinationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.name.text = destination.name;
    cell.destination = destination;
    //Adding SWTableViewCell stuff
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.718 green:0.718 blue:0.796 alpha:1.0] title:@"Editar"];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1 green:0.125 blue:0.125 alpha:1.0]
                                                title:@"Excluir"];
    
    cell.delegate = self;
    cell.rightUtilityButtons = rightUtilityButtons;
    
    if(index == selectedRow)
    {
        cell.checkMarkerImage.hidden = NO;
    }
    else
    {
        cell.checkMarkerImage.hidden = YES;
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUPListDestinationTableViewCell* cell = (WUPListDestinationTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    self.alreadySelectedDesination = cell.destination;
    
    selectedRow = [indexPath row];
    [tableView reloadData];
}

#pragma mark - Actions methods

- (IBAction)touchUpNavBarCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.delegate){
            [self.delegate pickedADestination:[self.destinationsArray objectAtIndex:selectedRow]];
        }
    }];
}

- (IBAction)touchUpNavBarAddButton:(id)sender {
    [self performSegueWithIdentifier:@"ListDestinationToSubscribeDestinationSegue" sender:sender];
}

#pragma mark - SWTableViewCell methods

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            Destination* destinationItem = [self.destinationsArray objectAtIndex:[cellIndexPath row]];
            self.alreadySelectedDesination = destinationItem;
            [self performSegueWithIdentifier:@"ListDestinationToSubscribeDestinationSegue" sender:self];
            
            break;
        }
        case 1:
        {
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            Destination* destinationItem = [self.destinationsArray objectAtIndex:[cellIndexPath row]];
            [self.managedObjectContext deleteObject:destinationItem];
            [self.managedObjectContext save:nil];
            [self.destinationsArray removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        }
        default:
            break;
    }
}


@end
