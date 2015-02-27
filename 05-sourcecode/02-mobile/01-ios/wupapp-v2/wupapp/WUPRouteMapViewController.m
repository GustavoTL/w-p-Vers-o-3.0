//
//  WUPRouteMapViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/6/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPRouteMapViewController.h"
#import "WUPGooglePlacesAPIService.h"

@interface WUPRouteMapViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *navBarIniciarButton;
@property (weak, nonatomic) IBOutlet UILabel *noRouteFoundLabel;
@property (weak, nonatomic) IBOutlet UIButton *noRouteFoundButton;

@property (weak, nonatomic) IBOutlet UIView *mapView;

@property (weak, nonatomic) IBOutlet UIView *containerTravelInfo;
@property (weak, nonatomic) IBOutlet UILabel *destinationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelTimeDescriptiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelDistanceDescriptiveLabel;


@property (weak, nonatomic) IBOutlet UILabel *descriptiveFirstLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptiveSecondLineLabel;

@property (strong,nonatomic) NSObject *lastLocalNotification;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation* location;

@property (nonatomic, assign) BOOL isLoadMap;

@end

@implementation WUPRouteMapViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDatabaseConnection];
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Route Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI {
    
    self.descriptiveFirstLineLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.descriptiveSecondLineLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    
    self.destinationNameLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:12.5f];
    self.travelTimeLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:12.5f];
    self.travelDistanceLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:12.5f];
    
    self.travelDistanceDescriptiveLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:12.5f];
    self.travelTimeDescriptiveLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:12.5f];
    self.destinationAddressLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:12.5f];
    
    self.noRouteFoundLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:13.0f];
    self.noRouteFoundButton.titleLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //Changing TabBar Appearance
    UITabBar *tabBar = self.tabBarController.tabBar;
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)]) {
        
        // set it just for this instance
        [tabBar setBackgroundImage:[UIImage imageNamed:@"navbar_route_image"]];
    }
    
    
    
    self.isLoadMap = FALSE;
    
    [self cleanIconBadgeNumber];
    [self updateLastLocalNotification];
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    
//    SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
//        [self.locationManager respondsToSelector:requestSelector]) {
//        ((void (*)(id, SEL))[self.locationManager methodForSelector:requestSelector])(self.locationManager, requestSelector);
//        [self.locationManager startUpdatingLocation];
//    } else {
//        [self.locationManager startUpdatingLocation];
//    }
//    
//    [self.locationManager startUpdatingLocation];
    
    NSLog(@"viewWillAppear MAPA %@", self.lastLocalNotification);
    
    if(self.lastLocalNotification) {
    
        self.containerTravelInfo.hidden = NO;
        [self.containerTravelInfo startLoadingAnimation];
        
        if(self.location != NULL) {
        
            [self updateRouteOnMap];
        }
    
    } else {
        
        self.containerTravelInfo.hidden = YES;
        self.noRouteFoundButton.hidden = NO;
        self.noRouteFoundLabel.hidden = NO;
        self.mapView.hidden = YES;
        self.navBarIniciarButton.enabled = NO;
    }
}

#pragma mark - Actions methods
- (IBAction)touchUpNavBarIniciarButton:(id)sender {
    
    Alarm  *alarm ;
    
    if([self.lastLocalNotification isKindOfClass:[UILocalNotification class]]) {
    
        alarm = [self parseLocalNotification:(UILocalNotification*)self.lastLocalNotification];
    
    } else{
        
        alarm = (Alarm*)self.lastLocalNotification;
    }
    
    WUPUIWazeActivity *ca = [[WUPUIWazeActivity alloc]init];
    ca.latitude = [alarm.destination.latitude doubleValue];
    ca.longitude = [alarm.destination.longitude doubleValue];
    
    WUPUIGoogleMapsActivity *ga = [[WUPUIGoogleMapsActivity alloc]init];
    ga.latitude = [alarm.destination.latitude doubleValue];
    ga.longitude = [alarm.destination.longitude doubleValue];
    
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:[NSArray arrayWithObjects:ca,ga,nil]];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeSaveToCameraRoll];

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)touchUpNoRouteFoundButton:(id)sender {
    self.navigationController.tabBarController.selectedIndex = 1;
}


#pragma mark - UI methods

-(void) updateLastLocalNotification {
    
    NSDate* date = [NSDate date];
    //Checking LocalNotifications
    NSMutableArray* arrayNotifications = [[self scheduledMasterLocalNotifications] mutableCopy];
    [arrayNotifications addObjectsFromArray:[Alarm loadAllOneTimeOnly:self.managedObjectContext]];
    
    if([arrayNotifications count]) {
        
        NSArray *sorted = [arrayNotifications sortedArrayUsingComparator:^NSComparisonResult(NSObject *obj1, NSObject *obj2) {

            NSDate *next1;
            NSDate *next2;
            
            if([obj1 isKindOfClass:[UILocalNotification class]]) {
                
                next1 = [(UILocalNotification*)obj1 lastFireDateBeforeDate:date];
                
            } else {
                
                next1 = ((Alarm*)obj1).whenTime;
            }
            
            if([obj2 isKindOfClass:[UILocalNotification class]]) {
                
                next2 = [(UILocalNotification*)obj2 lastFireDateBeforeDate:date];
            
            } else {
                
                next2 = ((Alarm*)obj2).whenTime;
            }
            
//            NSLog(@"%s Data1: %@ Data2: %@",__PRETTY_FUNCTION__,next1,next2);
            return [next1 compare:next2];
        }];
        
//#ifdef DEBUG
//        for(UILocalNotification* local in arrayNotifications)
//        {
//            NSLog(@"%s %@",__PRETTY_FUNCTION__,[local lastFireDateBeforeDate:date]);
//        }
//#endif
        
        self.lastLocalNotification = [sorted firstObject];//[sorted lastObject];

    } else {
        
        self.lastLocalNotification = nil;
    }
}

-(void) updateRouteOnMap {
    
    if(self.lastLocalNotification) {
        
        self.noRouteFoundLabel.hidden = YES;
        self.noRouteFoundButton.hidden = YES;
        self.mapView.hidden = NO;
        self.navBarIniciarButton.enabled = YES;
        
        [self.mapView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        MapView* mapView = [[MapView alloc] initWithFrame:
                            CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)] ;
        
        [self.mapView addSubview:mapView];
        
        //Getting Alarm from LocalNotification
        Alarm  *alarm ;
        
        if([self.lastLocalNotification isKindOfClass:[UILocalNotification class]]) {
            
            alarm = [self parseLocalNotification:(UILocalNotification*)self.lastLocalNotification];
        
        } else {
            
            alarm = (Alarm*)self.lastLocalNotification;
        }
        
        //Adding Routes
        Place* home = [[Place alloc] init] ;
        home.name = NSLocalizedString(@"estou_aqui", nil);//@"Estou aqui";
        home.latitude = self.location.coordinate.latitude;
        home.longitude = self.location.coordinate.longitude;
        
        Place* office = [[Place alloc] init];
        office.name = alarm.destination.name;
        office.latitude = [alarm.destination.latitude doubleValue];
        office.longitude = [alarm.destination.longitude doubleValue];
        
        [mapView showRouteFrom:home to:office];
        
        //Updating Info View
        WUPNokiaTrafficConditionsService* trafficService = [[WUPNokiaTrafficConditionsService alloc]init];
        
        [trafficService calculateRouteAndTravelTimeUsing:self.location.coordinate
                                          AndDestination:CLLocationCoordinate2DMake([alarm.destination.latitude doubleValue],
                                                                                    [alarm.destination.longitude doubleValue])
                                                 success:^(int ETATime,int distance, NSArray *route) {
            
            [self.containerTravelInfo stopLoadingAnimation];
            
            long seconds = ETATime;
            
            int hour = (int)seconds / 3600;
            int mins = (seconds % 3600) / 60;
            
            if(hour == 0) {
                
                self.travelTimeLabel.text = [NSString stringWithFormat:@"%dm",mins];
            
            } else {
                
                self.travelTimeLabel.text = [NSString stringWithFormat:@"%dh %dm",hour,mins];
            }
            
            self.travelDistanceLabel.text = [NSString stringWithFormat:@"%dkm",(distance/1000)];
            self.destinationNameLabel.text = [NSString stringWithFormat:@"%@:",alarm.destination.name];
            self.destinationAddressLabel.text = [alarm.destination.address capitalizedString];

            mapView.routes = route;
            [mapView drawRoute];
            //[mapView updateRouteView];
            [mapView centerMap];
            
        } failure:^{
            
            [self.containerTravelInfo stopLoadingAnimation];
        
        }];
    
    } else {
        
        self.noRouteFoundButton.hidden = NO;
        self.noRouteFoundLabel.hidden = NO;
        self.mapView.hidden = YES;
        self.navBarIniciarButton.enabled = NO;
    }
}

- (CLLocationCoordinate2D)coordinateWithLocation:(NSDictionary*)location {
    
    double latitude = [[location objectForKey:@"lat"] doubleValue];
    double longitude = [[location objectForKey:@"lng"] doubleValue];
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}

#pragma mark - MapView methods

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer *polylineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:204/255. green:45/255. blue:70/255. alpha:1.0];
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}

-(void)updateLocation:(CLLocation *)location {
    
    if(self.location != NULL) {
    
        CLLocationCoordinate2D oldLocation = self.location.coordinate;
        CLLocationCoordinate2D newLocation = location.coordinate;
        
        double raio = [WUPGooglePlacesAPIService distanceBetweenLat1:oldLocation.latitude
                                                                lon1:oldLocation.longitude
                                                                lat2:newLocation.latitude
                                                                lon2:newLocation.longitude];
        
        if(raio > 10) {
            
            self.location = location;
            [self updateRouteOnMap];
        }
        
    } else {
    
        self.location = location;
        
        if(!self.isLoadMap) {
            
            self.isLoadMap = true;
            [self updateRouteOnMap];
        }
    }
}

#pragma mark - CLLocationManagerDelegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    [self updateRouteOnMap];
}

-(Alarm*) parseLocalNotification:(UILocalNotification*) localNotification {
    
    //Getting Alarm from LocalNotification
    NSDictionary* userInfoDict = localNotification.userInfo;
    NSURL *reconstructedClassURL = [NSURL URLWithString:[userInfoDict objectForKey:[WUPConstants OBJECT_ABSOLUTEURL_LOCALNOTIFICATION]]];
    NSURL *reconstructedInstanceURL = [reconstructedClassURL URLByAppendingPathComponent:[userInfoDict objectForKey:[WUPConstants OBJECT_LASTPATH_LOCALNOTIFICATION]]];
    NSManagedObjectID *objectID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:reconstructedInstanceURL];
    Alarm  *alarm = (Alarm*)[self.managedObjectContext objectWithID:objectID];
    
    return alarm;
}
@end
