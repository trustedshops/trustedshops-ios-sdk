//
//  TRSProductDetailViewController.h
//  trustbadge_iOS
//
//  Created by mkalmes on 7/14/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRSProductTableViewController.h"

@interface TRSProductDetailViewController : UIViewController <TRSProductSelectionDelegate>

@property (nonatomic, copy) NSDictionary *product;

@end
