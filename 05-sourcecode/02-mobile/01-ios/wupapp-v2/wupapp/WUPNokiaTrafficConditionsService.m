//
//  WUPNokiaTrafficConditionsService.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/4/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPNokiaTrafficConditionsService.h"

#define NOKIA_APP_ID @"GE8gkD7FPvvaTXP0cXWM"
#define NOKIA_APP_CODE @"NCGRlH4IuN5_GXJt_ccLAg"

@implementation WUPNokiaTrafficConditionsService

-(void) calculateRouteAndTravelTimeUsing:(CLLocationCoordinate2D) myLocation AndDestination:(CLLocationCoordinate2D) destination success:(void (^)(int ETATime,int distance, NSArray *root))success
                              failure:(void (^)())failure {
    
    NSString* urlLocation = [NSString stringWithFormat:@"http://route.cit.api.here.com/routing/7.2/calculateroute.json?app_id=%@&app_code=%@&mode=fastest;car;traffic:enabled&waypoint0=geo!%f,%f&waypoint1=geo!%f,%f",NOKIA_APP_ID,NOKIA_APP_CODE,myLocation.latitude,myLocation.longitude,destination.latitude,destination.longitude];
    
    NSURL *URL = [NSURL URLWithString:urlLocation];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        @try {
            NSDictionary* responseJSONObj = [responseObject objectForKey:@"response"];
            NSArray* routeArray = [responseJSONObj objectForKey:@"route"];
            
            NSArray* maneuverJSONObj = [[[[routeArray firstObject] objectForKey:@"leg"] objectAtIndex:0] objectForKey:@"maneuver"];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < maneuverJSONObj.count; i ++) {
                                
                NSDictionary* positionJSONObj = [[maneuverJSONObj objectAtIndex:i] objectForKey:@"position"];
                
                CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[positionJSONObj objectForKey:@"latitude"] floatValue] longitude:[[positionJSONObj objectForKey:@"longitude"] floatValue]];
                [array addObject:loc];
            }
            
            NSDictionary* summaryJSONObj = [[routeArray firstObject] objectForKey:@"summary"];
            //We add a padding value to ensure people will get there even earlier than expected
            success(([[summaryJSONObj objectForKey:@"trafficTime"] intValue] + [WUPConstants NUMBER_PADDING_ALARMS:[self distanceBetweenLat1:myLocation.latitude lon1:myLocation.longitude lat2:destination.latitude lon2:destination.longitude]]),[[summaryJSONObj objectForKey:@"distance"] intValue], array);
            
        } @catch (NSException *exception) {
            failure();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure();
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

-(void) calculateRouteTravelTimeUsing:(CLLocationCoordinate2D) myLocation AndDestination:(CLLocationCoordinate2D) destination success:(void (^)(int ETATime,int distance))success
                                        failure:(void (^)())failure {
    
    NSString* urlLocation = [NSString stringWithFormat:@"http://route.cit.api.here.com/routing/7.2/calculateroute.json?app_id=%@&app_code=%@&mode=fastest;car;traffic:enabled&waypoint0=geo!%f,%f&waypoint1=geo!%f,%f",NOKIA_APP_ID,NOKIA_APP_CODE,myLocation.latitude,myLocation.longitude,destination.latitude,destination.longitude];
    
    NSLog(@"urlLocation %@", urlLocation);
    
    NSURL *URL = [NSURL URLWithString:urlLocation];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        @try {
            NSDictionary* responseJSONObj = [responseObject objectForKey:@"response"];
            NSArray* routeArray = [responseJSONObj objectForKey:@"route"];
            NSDictionary* summaryJSONObj = [[routeArray firstObject] objectForKey:@"summary"];
            //We add a padding value to ensure people will get there even earlier than expected
            success(([[summaryJSONObj objectForKey:@"trafficTime"] intValue] + [WUPConstants NUMBER_PADDING_ALARMS:[self distanceBetweenLat1:myLocation.latitude lon1:myLocation.longitude lat2:destination.latitude lon2:destination.longitude]]),[[summaryJSONObj objectForKey:@"distance"] intValue]);
            
        } @catch (NSException *exception) {
            failure();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure();
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:urlLocation parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    
//        NSLog(@"calculateRouteTravelTimeUsing -> JSON: \n%@", responseObject);
//
//        @try {
//            NSDictionary* responseJSONObj = [responseObject objectForKey:@"response"];
//            NSArray* routeArray = [responseJSONObj objectForKey:@"route"];
//            NSDictionary* summaryJSONObj = [[routeArray firstObject] objectForKey:@"summary"];
//            //We add a padding value to ensure people will get there even earlier than expected
//            success(([[summaryJSONObj objectForKey:@"trafficTime"] intValue] + [WUPConstants NUMBER_PADDING_ALARMS:[self distanceBetweenLat1:myLocation.latitude lon1:myLocation.longitude lat2:destination.latitude lon2:destination.longitude]]),[[summaryJSONObj objectForKey:@"distance"] intValue]);
//        
//        } @catch (NSException *exception) {
//            failure();
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        failure();
//    }];
}

- (double) distanceBetweenLat1:(double)lat1 lon1:(double)lon1
                          lat2:(double)lat2 lon2:(double)lon2 {
    //degrees to radians
    double lat1rad = lat1 * M_PI/180;
    double lon1rad = lon1 * M_PI/180;
    double lat2rad = lat2 * M_PI/180;
    double lon2rad = lon2 * M_PI/180;
    
    //deltas
    double dLat = lat2rad - lat1rad;
    double dLon = lon2rad - lon1rad;
    
    double a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1rad) * cos(lat2rad);
    double c = 2 * asin(sqrt(a));
    double R = 6372.8;
    return R * c;
}

@end
