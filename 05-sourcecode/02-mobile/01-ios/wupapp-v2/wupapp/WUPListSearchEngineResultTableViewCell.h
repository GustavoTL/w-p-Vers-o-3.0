//
//  WUPListSearchEngineResultTableViewCell.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 9/20/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WUPGooglePlacesAPISearchResult.h"

@interface WUPListSearchEngineResultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeDistanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkerImage;

@property (strong, nonatomic) WUPGooglePlacesAPISearchResult* googlePlacesAPISearchResult;

@end
