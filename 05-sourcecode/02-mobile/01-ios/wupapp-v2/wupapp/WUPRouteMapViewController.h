//
//  WUPRouteMapViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/6/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPBaseDatabaseLocalNotificationViewController.h"

//Libraries
#import <MapKit/MapKit.h>

//Categories
#import "UILocalNotification+LastFireDate.h"
#import "UIView+LoadingWithActivityIndicator.h"
#import "UILocalNotification+NextFireDate.h"

//Map Routings
#import "MapView.h"
#import "Place.h"

//Models
#import "Alarm.h"
#import "Destination.h"
#import "Alarm+Database.h"
#import "Destination+Database.h"

//Services
#import "WUPNokiaTrafficConditionsService.h"

//UIActivities
#import "WUPUIWazeActivity.h"
#import "WUPUIGoogleMapsActivity.h"

@interface WUPRouteMapViewController : WUPBaseDatabaseLocalNotificationViewController<MKMapViewDelegate,CLLocationManagerDelegate>

@property (strong,nonatomic) NSObject *lastLocalNotification;

@end
