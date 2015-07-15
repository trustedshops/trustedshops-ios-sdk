//
//  UISplitViewController+TRSCompatiblyLayer.m
//  trustbadge_iOS
//
//  Created by mkalmes on 7/15/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import "UISplitViewController+TRSCompatiblyLayer.h"

@implementation UISplitViewController (TRSCompatiblyLayer)

- (void)tcl_setPreferredDisplayMode:(NSInteger)displayMode {
    if ([self respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [self setPreferredDisplayMode:displayMode];
    }
}

@end
