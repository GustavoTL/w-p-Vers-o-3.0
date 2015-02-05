//
//  WUPGooglePlacesAPIService.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 8/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPGooglePlacesAPIService.h"

#define GOOGLEAPIS_SERVERKEY @"AIzaSyCy7YSHsDdbY16BQICWFmTuMBxalIXPw0I"
#define GOOGLEAPIS_PLACESAPI_DEFAULT_RADIUS 50000

@implementation WUPGooglePlacesAPIService

-(void) searchLocationsWithName:(NSString*) name AndLocation:(CLLocationCoordinate2D) myLocation success:(void (^)(NSArray* arrayLocationsFound)) success failure:(void (^)()) failure
{
    
    NSString* urlLocation = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&location=%f,%f&radius=%d&key=%@",[name urlencode],myLocation.latitude,myLocation.longitude,GOOGLEAPIS_PLACESAPI_DEFAULT_RADIUS, GOOGLEAPIS_SERVERKEY];
    
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,urlLocation);
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlLocation parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

#ifdef  __DEBUG_FINEST__
        NSLog(@"%s JSON: %@", __PRETTY_FUNCTION__, responseObject);
#endif
        @try {
            NSMutableArray * foundLocationsArray = [[NSMutableArray alloc] init];

            NSArray* resultsJSONArray = [responseObject objectForKey:@"results"];
            for(int i=0; i < [resultsJSONArray count]; i++)
            {
                NSDictionary* resultJSONObject = [resultsJSONArray objectAtIndex:i];
                NSDictionary* geometryJSONObject = [resultJSONObject objectForKey:@"geometry"];
                NSDictionary* locationJSONObject = [geometryJSONObject objectForKey:@"location"];
                
                WUPGooglePlacesAPISearchResult* googlePlaceAPIResult = [[WUPGooglePlacesAPISearchResult alloc] init];
                googlePlaceAPIResult.name = [resultJSONObject objectForKey:@"name"];
                googlePlaceAPIResult.formattedAddress = [resultJSONObject objectForKey:@"formatted_address"];
                googlePlaceAPIResult.location = CLLocationCoordinate2DMake([[locationJSONObject objectForKey:@"lat"] doubleValue], [[locationJSONObject objectForKey:@"lng"] doubleValue]);
                googlePlaceAPIResult.distanceFromHere = [self distanceBetweenLat1:myLocation.latitude lon1:myLocation.longitude lat2:googlePlaceAPIResult.location.latitude lon2:googlePlaceAPIResult.location.longitude];
                
                [foundLocationsArray addObject:googlePlaceAPIResult];
            }

            success(foundLocationsArray);
        }
        @catch (NSException *exception) {
            failure();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef  __DEBUG_FINEST__
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
#endif
        failure();
    }];
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
