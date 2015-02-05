//
//  WUPListSearchEngineResultViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 9/20/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPBaseDatabaseViewController.h"

//Libraries
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD/MBProgressHUD.h>

//UITableViewCells
#import "WUPListSearchEngineResultTableViewCell.h"

//Services
#import "WUPGooglePlacesAPIService.h"
#import "WUPGooglePlacesAPISearchResult.h"

@protocol WUPListSearchEngineResultViewControllerDelegate <NSObject>

-(void) pickedAGooglePlacesAPISearchResult:(WUPGooglePlacesAPISearchResult*) result;

@end

@interface WUPListSearchEngineResultViewController : WUPBaseDatabaseViewController<UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate>

@property(nonatomic,strong) NSString* searchTerm;
@property(strong,nonatomic) id<WUPListSearchEngineResultViewControllerDelegate> delegate;

@end
