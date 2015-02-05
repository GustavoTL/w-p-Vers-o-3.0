//
//  WUPDateUtils.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUPDateUtils : NSObject

+(NSString*) timeElapsedBetweenDateFrom:(NSString*) dateFrom AndDateTo:(NSString*) dateTo AndFormat:(NSString*) format;

+(NSString*) timeElapsedLongFormatBetweenDateFrom:(NSString*) dateFrom AndDateTo:(NSString*) dateTo AndFormat:(NSString*) format;

+(NSString*) timeElapsedBetweenDateFrom:(NSDate*) dateFrom AndDateTo:(NSDate*) dateTo;

+(NSString*) timeElapsedLongFormatBetweenDateFrom:(NSDate*) dateFrom AndDateTo:(NSDate*) dateTo;

+(long) minutesBetweenDateFrom:(NSDate*) dateFrom AndDateTo:(NSDate*) dateTo;

+(NSDate*) convertToDate:(NSString*) date WithFormat:(NSString*) format;

+(NSString*) convertToString:(NSDate*) date WithFormat:(NSString*) format;

+(NSDate*) convertDateInUTC:(NSDate*)date;

+(NSString*) convertDateInUTCString:(NSDate*)date;

+(NSDate*) convertDateInGMT:(NSDate*)date;

@end
