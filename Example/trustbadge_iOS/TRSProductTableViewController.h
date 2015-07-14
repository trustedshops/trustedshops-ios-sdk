//
//  TRSProductTableViewController.h
//  trustbadge_iOS
//
//  Created by mkalmes on 7/14/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TRSProductSelectionDelegate <NSObject>

@required

- (void)didSelectNewProduct:(NSDictionary *)newProduct;

@end


@interface TRSProductTableViewController : UITableViewController

@property (nonatomic, copy, readonly) NSArray *products;
@property (nonatomic, assign) id <TRSProductSelectionDelegate> delegate;

@end
