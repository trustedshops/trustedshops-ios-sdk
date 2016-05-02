//
//  TRSViewController.m
//  Trustbadge_Example
//
//  Created by Gero Herkenrath on 02/05/16.
//  Copyright © 2016 Trusted Shops. All rights reserved.
//

#import "TRSViewController.h"
#import "TRSPickerViewController.h"
#import "TRSDatePickerViewController.h"

@interface TRSViewController () <TRSDatePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tsIDField;
@property (weak, nonatomic) IBOutlet UITextField *orderNoField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UITextField *currencyField;
@property (weak, nonatomic) IBOutlet UITextField *paymentTypeField;
@property (weak, nonatomic) IBOutlet UITextField *estDeliveryDateField;

- (IBAction)submitTestOrder:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)emptyDateField:(id)sender;

@end

@implementation TRSViewController

#pragma mark Displaying the Seal

// if the TS ID changed, we simply create a new Trustbadge and add it
- (void)viewWillAppear:(BOOL)animated {
	
}

#pragma mark Submitting an order to Trusted Shops

- (IBAction)submitTestOrder:(id)sender {
	
}

#pragma mark UI-only related methods (no importance for SDK)

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"tsidSelection"]) {
		((TRSPickerViewController *)(segue.destinationViewController)).targetField = self.tsIDField;
		((TRSPickerViewController *)(segue.destinationViewController)).mode = TRSSelectTSID;
	} else if ([segue.identifier isEqualToString:@"currencySelection"]) {
		((TRSPickerViewController *)(segue.destinationViewController)).targetField = self.currencyField;
		((TRSPickerViewController *)(segue.destinationViewController)).mode = TRSSelectCurrency;
	} else if ([segue.identifier isEqualToString:@"paymentTypeSelection"]) {
		((TRSPickerViewController *)(segue.destinationViewController)).targetField = self.paymentTypeField;
		((TRSPickerViewController *)(segue.destinationViewController)).mode = TRSSelectPaymentType;
	} else {
		((TRSDatePickerViewController *)(segue.destinationViewController)).delegate = self;
		if (self.estDeliveryDateField.text && ![self.estDeliveryDateField.text isEqualToString:@""]) {
			NSDateFormatter *formatter = [NSDateFormatter new];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *date = [formatter dateFromString:self.estDeliveryDateField.text];
			[((TRSDatePickerViewController *)(segue.destinationViewController)) setSelectedDate:date];
		}
		
	}
}

- (IBAction)dismissKeyboard:(id)sender {
	[sender resignFirstResponder];
}

- (IBAction)emptyDateField:(id)sender {
	[self.estDeliveryDateField setText:@""]; // reset to default
}

- (void)selectedDate:(NSDate *)date {
	NSDateFormatter *formatter = [NSDateFormatter new];
	[formatter setDateFormat:@"yyyy-MM-dd"];
	self.estDeliveryDateField.text = [formatter stringFromDate:date];
}

@end
