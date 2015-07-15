//
//  UIViewController+TRSViewControllerShowing.m
//  trustbadge_iOS
//
//  Created by mkalmes on 7/15/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import "UIViewController+TRSViewControllerShowing.h"

@implementation UIViewController (TRSViewControllerShowing)

- (BOOL)trs_willShowingDetailViewControllerPush {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(traitCollection)]) {
        return UIScreen.mainScreen.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
    } else {
        return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    }
}

@end
