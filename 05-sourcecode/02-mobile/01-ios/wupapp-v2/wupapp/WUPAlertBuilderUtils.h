//
//  WUPAlertBuilderUtils.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUPAlertBuilderUtils : NSObject

+(UIAlertView*) buildAlertForMissingInformation:(NSString*) fieldName;
+(UIAlertView*) buildAlertForAddressNotFound;
+(UIAlertView*) buildAlertForMissingInformation;
+(UIAlertView*) buildAlertForAddressNotFoundOnGooglePlacesAPI;
+(UIAlertView*) buildAlertForLocationNotFoundAirplaneMode;
+(UIAlertView*) buildAlertForLocationNotFoundUserDenied;
+(UIAlertView*) buildAlertForLocationNotFoundUnknownError;

@end
