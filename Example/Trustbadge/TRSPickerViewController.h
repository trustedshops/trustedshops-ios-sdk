//
//  TRSPickerViewController.h
//  Trustbadge_Example
//
//  Created by Gero Herkenrath on 02/05/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TRSPickerMode) {
	TRSSelectTSID,
	TRSSelectCurrency,
	TRSSelectPaymentType
};

@interface TRSPickerViewController : UIViewController

@property (weak, nonatomic) UITextField *targetField;
@property (nonatomic, assign) TRSPickerMode mode;

@end
