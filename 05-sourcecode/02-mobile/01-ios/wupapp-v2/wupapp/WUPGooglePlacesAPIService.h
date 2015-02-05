//
//  WUPGooglePlacesAPIService.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 8/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

//Libraries
#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>

//Models
#import "WUPGooglePlacesAPISearchResult.h"

//Categories
#import "NSString+NSString_Extended.h"

@interface WUPGooglePlacesAPIService : NSObject

-(void) searchLocationsWithName:(NSString*) name AndLocation:(CLLocationCoordinate2D) myLocation success:(void (^)(NSArray* arrayLocationsFound)) success failure:(void (^)()) failure;

@end