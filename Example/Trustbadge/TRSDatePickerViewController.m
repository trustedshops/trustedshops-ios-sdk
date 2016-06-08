//
//  TRSDatePickerViewController.m
//  Trustbadge_Example
//
//  Created by Gero Herkenrath on 02/05/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "TRSDatePickerViewController.h"

@interface TRSDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) NSDate *initialDate;

@end

@implementation TRSDatePickerViewController

- (void)viewWillDisappear:(BOOL)animated {
	if (self.delegate) {
		[self.delegate selectedDate:self.datePicker.date];
	}
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.initialDate) self.datePicker.date = self.initialDate;
    [super viewWillAppear:animated];
}

- (void)setSelectedDate:(NSDate *)date {
	self.initialDate = date; // can't set it immediately due to view rendering
}

@end
