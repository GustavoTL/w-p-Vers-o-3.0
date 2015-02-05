//
//  WUPListSearchEngineResultTableViewCell.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 9/20/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPListSearchEngineResultTableViewCell.h"

@implementation WUPListSearchEngineResultTableViewCell

-(void)awakeFromNib
{
    self.placeNameLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:18.0f];
    self.placeAddressLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.placeDistanceLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:15.0f];
}

-(void)setGooglePlacesAPISearchResult:(WUPGooglePlacesAPISearchResult *)googlePlacesAPISearchResult
{
    if(googlePlacesAPISearchResult){
        self.placeNameLabel.text = googlePlacesAPISearchResult.name;
        self.placeAddressLabel.text = googlePlacesAPISearchResult.formattedAddress;
        self.placeDistanceLabel.text = [NSString stringWithFormat:@"%.2f km",googlePlacesAPISearchResult.distanceFromHere];
    }
}

@end
