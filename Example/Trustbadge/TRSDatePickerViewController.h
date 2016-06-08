//
//  TRSDatePickerViewController.h
//  Trustbadge_Example
//
//  Created by Gero Herkenrath on 02/05/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TRSDatePickerViewControllerDelegate <NSObject>

@required
- (void)selectedDate:(NSDate *)date;

@end

@interface TRSDatePickerViewController : UIViewController

@property (nonatomic, weak) id<TRSDatePickerViewControllerDelegate> delegate;

- (void)setSelectedDate:(NSDate *)date;

@end
