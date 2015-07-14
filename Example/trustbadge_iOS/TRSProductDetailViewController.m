//
//  TRSProductDetailViewController.m
//  trustbadge_iOS
//
//  Created by mkalmes on 7/14/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import "TRSProductDetailViewController.h"

@interface TRSProductDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *productSKULabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;

@end

@implementation TRSProductDetailViewController

- (void)viewDidLoad {
    [self refreshUI];

    [super viewDidLoad];
}

- (void)refreshUI {
    self.productTitleLabel.text = self.product[@"title"];
    self.productSKULabel.text = self.product[@"sku"];
    self.productDescriptionLabel.text = self.product[@"description"];
}

- (void)setProduct:(NSDictionary *)product {
    if (_product == product) {
        return;
    }

    _product = product;
    [self refreshUI];
}

@end
