//
//  TRSPickerViewController.m
//  Trustbadge_Example
//
//  Created by Gero Herkenrath on 02/05/16.
//  Copyright © 2016 Gero Herkenrath. All rights reserved.
//

#import "TRSPickerViewController.h"

@interface TRSPickerViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation TRSPickerViewController

-(void)viewWillDisappear:(BOOL)animated {
	NSInteger selectedRow = [self.picker selectedRowInComponent:0];
	self.targetField.text = [self currentContents][selectedRow];
}

-(void)viewWillAppear:(BOOL)animated {
	NSInteger lastIndex = [[self currentContents] indexOfObject:self.targetField.text];
	[self.picker selectRow:lastIndex inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[self currentContents] count]; // only ever 1 component, so don't bother checking
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self currentContents][row];
}

- (NSArray *)currentContents {
	switch (self.mode) {
  case TRSSelectTSID:
			return [self tsids];
			break;
  case TRSSelectCurrency:
			return [self currencies];
			break;
  case TRSSelectPaymentType:
			return [self paymentTypes];
			break;
			
  default:
			return nil;
			break;
	}
}

- (NSArray *)tsids {
	return @[@"X330A2E7D449E31E467D2F53A55DDD070", // CH demo shop
			 @"XCD7B06A865895BD55F9B86C6BE099CC7", // consumer membership
			 @"X2664C3138F8E4799063F84A7B790179E"  // reviews only!
			 ];
}

- (NSArray *)currencies {
	return @[@"EUR", @"USD", @"AUD", @"CAD", @"CHF", @"DKK", @"GBP", @"JPY", @"NZD", @"SEK", @"PLN",
			 @"NOK", @"BGN", @"RON", @"RUB", @"TRY", @"CZK", @"HUF", @"HRK"];
}

- (NSArray *)paymentTypes {
	return @[@"DIRECT_DEBIT", @"CASH_ON_PICKUP", @"CLICKANDBUY", @"FINANCING", @"GIROPAY",
			 @"GOOGLE_CHECKOUT", @"CREDIT_CARD", @"LEASING", @"MONEYBOOKERS", @"CASH_ON_DELIVERY",
			 @"PAYBOX", @"PAYPAL", @"INVOICE", @"CHEQUE", @"SHOP_CARD", @"DIRECT_E_BANKING", @"T_PAY",
			 @"PREPAYMENT", @"AMAZON_PAYMENTS"];
}

@end
