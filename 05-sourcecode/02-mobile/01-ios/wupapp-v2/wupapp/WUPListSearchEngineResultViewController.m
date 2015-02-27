//
//  WUPListSearchEngineResultViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 9/20/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPListSearchEngineResultViewController.h"

@interface WUPListSearchEngineResultViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* resultArray; //Of WUPGooglePlacesAPISearchResult

//GPS Stuff
@property (strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation* location;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonSelect;

@end

@implementation WUPListSearchEngineResultViewController
long selectedRow;

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Search Engine Result Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI {
    
    self.barButtonSelect.enabled = FALSE;
    
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
    
    selectedRow = -1;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    if(self.locationManager) {
        
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - UITableViewDelegate methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"WUPListSearchEngineResultTableViewCell";
    long index = [indexPath row];
    
    WUPListSearchEngineResultTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    WUPGooglePlacesAPISearchResult* googlePlacesResult = [self.resultArray objectAtIndex:[indexPath row]];
    cell.googlePlacesAPISearchResult = googlePlacesResult;
    
    if(index == selectedRow) {
        
        cell.checkMarkerImage.hidden = NO;
        cell.contentView.backgroundColor = [UIColor whiteColor];
    
    } else {
        
        cell.checkMarkerImage.hidden = YES;
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.937 alpha:1.0];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    long index = [indexPath row];
    selectedRow = index;
    [tableView reloadData];
    
    self.barButtonSelect.enabled = TRUE;
}

#pragma mark - Actions methods
- (IBAction)touhUpNavBarCancelButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)touhUpNavBarSelectButton:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        
        if(self.delegate) {
            
            if(selectedRow != -1) {
                
                [self.delegate pickedAGooglePlacesAPISearchResult:[self.resultArray objectAtIndex:selectedRow]];
                
            } else {
                
                [self.delegate pickedAGooglePlacesAPISearchResult:nil];
            }
        }
    }];
}

#pragma mark - CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [self requestPlacesAPI];
    
}

- (void)locationManager: (CLLocationManager *)manager
       didFailWithError: (NSError *)error
{
    [manager stopUpdatingLocation];
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [WUPAlertBuilderUtils buildAlertForLocationNotFoundAirplaneMode];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [WUPAlertBuilderUtils buildAlertForLocationNotFoundUserDenied];
            [alert show];
        }
            break;
        default:
        {
            UIAlertView *alert = [WUPAlertBuilderUtils buildAlertForLocationNotFoundUnknownError];
            [alert show];

        }
            break;
    }
}


#pragma mark - GooglePlacesAPI methods

-(void) requestPlacesAPI{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Buscando";
    
    WUPGooglePlacesAPIService* service = [[WUPGooglePlacesAPIService alloc] init];
    
    [service searchLocationsWithName:self.searchTerm AndLocation:self.location.coordinate success:^(NSArray *arrayLocationsFound) {
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
        self.resultArray = arrayLocationsFound;
        [self.tableView reloadData];
        
    } failure:^{
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
        UIAlertView* alert = [WUPAlertBuilderUtils buildAlertForAddressNotFoundOnGooglePlacesAPI];
        [alert show];
    }];
    
}

@end
