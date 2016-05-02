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
@import Trustbadge;

@interface TRSViewController () <TRSDatePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tsIDField;
@property (weak, nonatomic) IBOutlet UITextField *orderNoField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UITextField *currencyField;
@property (weak, nonatomic) IBOutlet UITextField *paymentTypeField;
@property (weak, nonatomic) IBOutlet UITextField *estDeliveryDateField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)submitTestOrder:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)emptyDateField:(id)sender;

// ### The following properties are relevant for adding a TRSTrustbadgeView object!
@property (weak, nonatomic) IBOutlet UIView *nibPlaceholder;
@property (strong, nonatomic) TRSTrustbadgeView *myTrustbadgeView;

@end

@implementation TRSViewController

#pragma mark Displaying the Seal

// if the TS ID changed, we simply create a new Trustbadge and add it
- (void)viewWillAppear:(BOOL)animated {
	if (!self.myTrustbadgeView || ![self.myTrustbadgeView.trustedShopsID isEqualToString:self.tsIDField.text]) {
		self.myTrustbadgeView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:self.tsIDField.text
																		 apiToken:@"THIS IS NOT NEEDED ATM"];
		self.myTrustbadgeView.customColor = [UIColor colorWithRed:(54.0 / 255.0)
															green:(203.0 / 255.0)
															 blue:(118.0 / 255.0)
															alpha:1.0];
		self.myTrustbadgeView.debugMode = YES; // CAREFUL when changing this!
		[self.nibPlaceholder addSubview:self.myTrustbadgeView];
		[self.myTrustbadgeView loadTrustbadgeWithFailureBlock:^(NSError *error) {
			if (error) {
				NSLog(@"The TrustbadgeView could not be loaded! Error: %@", error);
			}
		}];
	}
	
	[self updateUI];
}

#pragma mark Submitting an order to Trusted Shops

- (IBAction)submitTestOrder:(id)sender {
	// if we don't have all the needed data, just do nothing
	if (   !self.orderNoField.text || [self.orderNoField.text isEqualToString:@""]  ||
		   !self.emailField.text   || [self.emailField.text isEqualToString:@""]    ||
		   !self.amountField.text  || [self.amountField.text isEqualToString:@""]     ) {
		NSLog(@"Input error: some needed fields are empty");
		return;
	}
	
	double amount = [self.amountField.text doubleValue];
	NSDate *date = nil;
	if (self.estDeliveryDateField.text && ![self.estDeliveryDateField.text isEqualToString:@""]) {
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		date = [dateFormatter dateFromString:self.estDeliveryDateField.text];
	}
	
	TRSOrder *anOrder = [[TRSOrder alloc] initWithTrustedShopsID:self.tsIDField.text
														apiToken:@"NOT NEEDED AT THE ATM"
														   email:self.emailField.text
														 ordernr:self.orderNoField.text
														  amount:[NSNumber numberWithDouble:amount]
															curr:self.currencyField.text
													 paymentType:self.paymentTypeField.text
													deliveryDate:date];
	
	anOrder.debugMode = YES; // CAREFUL when changing this!
	
	// for now the demo app doesn't support products, this will come later
	
	[anOrder validateWithCompletionBlock:^(NSError * _Nullable error) {
		NSLog(@"%@uccessfully validated anOrder", error ? @"Uns" : @"S");
	}];
	[anOrder finishWithCompletionBlock:^(NSError * _Nullable error) {
		NSLog(@"Finished anOrder, user %@ insurance", anOrder.insuranceState == TRSUserDeclinedInsurance ? @"declined" : @"bought");
	}];
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
	[self updateUI];
}

- (IBAction)emptyDateField:(id)sender {
	[self.estDeliveryDateField setText:@""]; // reset to default
}

- (void)selectedDate:(NSDate *)date {
	NSDateFormatter *formatter = [NSDateFormatter new];
	[formatter setDateFormat:@"yyyy-MM-dd"];
	self.estDeliveryDateField.text = [formatter stringFromDate:date];
}

- (void)updateUI {
	[self checkSubmitButtonState];
	self.emailField.text = [self validateEmailString:self.emailField.text];
	self.amountField.text = [self validateAmountString:self.amountField.text];
}

- (NSString *)validateEmailString:(NSString *)email {
	if ([email containsString:@"@"]) { // does it have an @ in it?
		NSMutableArray *delimited = [[email componentsSeparatedByString:@"@"] mutableCopy];
		if (![[delimited lastObject] containsString:@"."]) { // a delimiter for the toplevel domain?
			return @"";
		}
		[delimited removeLastObject];
		NSString *front = [delimited componentsJoinedByString:@"@"];
		if ([front length] > 0) {
			return email;
		}
	}
	return @"";
}

- (NSString *)validateAmountString:(NSString *)amountString {
	if (amountString.floatValue == .0f) {
		return @"";
	} else {
		return [NSString stringWithFormat:@"%.2f", amountString.floatValue];
	}
}

- (void)checkSubmitButtonState {
	if (   !self.orderNoField.text || [self.orderNoField.text isEqualToString:@""]  ||
		   !self.emailField.text   || [self.emailField.text isEqualToString:@""]    ||
		   !self.amountField.text  || [self.amountField.text isEqualToString:@""]     ) {
		self.submitButton.enabled = NO;
	} else {
		self.submitButton.enabled = YES;
	}
}

@end
