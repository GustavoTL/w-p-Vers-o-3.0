//
//  WUPNokiaTrafficConditionsService.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/4/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

//Libraries
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>

@interface WUPNokiaTrafficConditionsService : NSObject

-(void) calculateRouteTravelTimeUsing:(CLLocationCoordinate2D) myLocation AndDestination:(CLLocationCoordinate2D) destination success:(void (^)(int ETATime,int distance))success
                              failure:(void (^)())failure;

-(void) calculateRouteAndTravelTimeUsing:(CLLocationCoordinate2D) myLocation AndDestination:(CLLocationCoordinate2D) destination success:(void (^)(int ETATime,int distance, NSArray *root))success
                              failure:(void (^)())failure;

@end
