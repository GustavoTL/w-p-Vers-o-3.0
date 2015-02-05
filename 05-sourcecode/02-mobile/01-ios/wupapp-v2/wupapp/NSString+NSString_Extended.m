//
//  NSString+NSString_Extended.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 8/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "NSString+NSString_Extended.h"

@implementation NSString (NSString_Extended)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString*) abreviateWeekdays
{
    NSArray* arrayWeekdays = [self componentsSeparatedByString:@", "];
    NSString* result = @"";
    
    for( int i=0; i < [arrayWeekdays count]; i++)
    {
        NSString* str = [arrayWeekdays objectAtIndex:i];
        result =[result stringByAppendingString:[[str substringToIndex:3] lowercaseString]];
        if(i != [arrayWeekdays count] -1)
        {
            result =[result stringByAppendingString:@", "];
        }
    }
    return result;
}

@end
