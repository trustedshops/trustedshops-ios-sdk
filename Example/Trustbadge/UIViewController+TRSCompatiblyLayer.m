//
//  UIViewController+TRSCompatiblyLayer.m
//  trustbadge_iOS
//
//  Created by mkalmes on 7/15/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import "UIViewController+TRSCompatiblyLayer.h"
#import "TRSProductDetailViewController.h"
#import "TRSProductTableViewController.h"

@implementation UIViewController (TRSCompatiblyLayer)

- (void)tcl_showDetailViewController:(UIViewController *)vc sender:(id)sender {
    if ([self respondsToSelector:@selector(showDetailViewController:sender:)]) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self showDetailViewController:navController sender:sender];
    } else {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            if ([vc conformsToProtocol:@protocol(TRSProductSelectionDelegate)]) {
                id <TRSProductSelectionDelegate> delegate = [(TRSProductTableViewController *)self productSelectionDelegate];
                if (delegate) {
                    if ([vc isKindOfClass:[TRSProductDetailViewController class]]) {
                        TRSProductDetailViewController *pvc = (TRSProductDetailViewController *)vc;
                        [delegate didSelectNewProduct:pvc.product];
                    }
                }
            }
        }
    }
}

@end
