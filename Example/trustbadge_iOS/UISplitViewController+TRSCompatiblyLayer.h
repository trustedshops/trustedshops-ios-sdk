//
//  UISplitViewController+TRSCompatiblyLayer.h
//  trustbadge_iOS
//
//  Created by mkalmes on 7/15/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISplitViewController (TRSCompatiblyLayer)

- (void)tcl_setPreferredDisplayMode:(NSInteger)displayMode;

@end
