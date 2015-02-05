//
//  WUPGooglePlacesAPISearchResult.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 8/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

//Libraries
#import <CoreLocation/CoreLocation.h>

@interface WUPGooglePlacesAPISearchResult : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* formattedAddress;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) double distanceFromHere;


@end
