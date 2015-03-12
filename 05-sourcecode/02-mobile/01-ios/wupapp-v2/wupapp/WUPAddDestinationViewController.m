//
//  WUPAddDestinationViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPAddDestinationViewController.h"

@interface WUPAddDestinationViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemSave;

@property(nonatomic) CLLocationCoordinate2D location;
@end

@implementation WUPAddDestinationViewController

BOOL foundAddress = NO;

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setupDatabaseConnection];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Add Destination Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


-(void) setupUI {
    
    if(self.selectedDestination) {
        
        self.barButtonItemSave.enabled = TRUE;
    
        self.nameTextField.text = self.selectedDestination.name;
        self.addressTextField.text = self.selectedDestination.address;
        [self showAddressOnMapView:CLLocationCoordinate2DMake([self.selectedDestination.latitude doubleValue], [self.selectedDestination.longitude doubleValue])];
    
    } else {
    
        self.barButtonItemSave.enabled = false;
    }
    
    [self.nameTextField setLeftPadding:15.0f];
    [self.addressTextField setLeftPadding:15.0f];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SubscribeDestinationToSearchEngineResultSegue"])
    {
        WUPListSearchEngineResultViewController* vc = segue.destinationViewController;
        vc.searchTerm = self.addressTextField.text;
        vc.delegate = self;
    }
}

#pragma mark - Actions methods
- (IBAction)touchUpNavBarSaveButton:(id)sender {
    
    if(![self.nameTextField.text isEqualToString:@""] && ![self.addressTextField.text isEqualToString:@""]){

        if(foundAddress) {
            
            Destination* destination;
            
            if(self.selectedDestination) {
            
                destination = self.selectedDestination;
            
            } else {
            
                destination = [Destination insertNewObjectInContext:self.managedObjectContext];
            
            }
            
            destination.name = self.nameTextField.text;
            destination.address = self.addressTextField.text;
            destination.alarm = nil;
            destination.latitude = [NSNumber numberWithDouble:self.location.latitude];
            destination.longitude = [NSNumber numberWithDouble:self.location.longitude];

            NSError* error;
            [self.managedObjectContext save:&error];
            if(!error) {
                
                NSLog(@"Saved successfully");
            
            } else {
                
                NSLog(@"Couldn't save");
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        
        } else {
            
            UIAlertView *view = [WUPAlertBuilderUtils buildAlertForAddressNotFound];
            [view show];
        }
        
    } else {
        
        UIAlertView *view = [WUPAlertBuilderUtils buildAlertForMissingInformation];
        [view show];
    }
    
}

- (IBAction)touchUpNavBarCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(textField == self.nameTextField) {
        
        [self.addressTextField becomeFirstResponder];
    
    } else if(textField == self.addressTextField) {
        
        if(![self.addressTextField.text isEqualToString:@""]) {
            
            [self performSegueWithIdentifier:@"SubscribeDestinationToSearchEngineResultSegue" sender:self];
            [self.addressTextField resignFirstResponder];
        
        } else {
            
            UIAlertView* alert = [WUPAlertBuilderUtils buildAlertForMissingInformation:@"endereço"];
            [alert show];
        }
    
    } else {
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UI methods
-(void) showAddressOnMapView:(CLLocationCoordinate2D) coord {

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 4.5 * 1609.34, 4.5 * 1609.34);

    [self.mapView setRegion:viewRegion animated:YES];
    [self.mapView regionThatFits:viewRegion];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:placemark];
     
    self.location = CLLocationCoordinate2DMake(placemark.coordinate.latitude, placemark.coordinate.longitude);
     
    foundAddress = YES;
}

#pragma mark - WUPListSearchEngineResultViewControllerDelegate methods
-(void)pickedAGooglePlacesAPISearchResult:(WUPGooglePlacesAPISearchResult *)result {
    
    if(result) {
        
        self.barButtonItemSave.enabled = TRUE;
        
        self.addressTextField.text = result.formattedAddress;
        [self showAddressOnMapView:result.location];
    }
}


@end
