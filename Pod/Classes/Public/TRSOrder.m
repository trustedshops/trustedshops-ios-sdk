//
//  TRSOrder.m
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import "TRSOrder.h"
#import "TRSConsumer.h"
#import "TRSConsumer+Private.h"
#import "TRSCheckoutViewController.h"
#import "TRSErrors.h"

@interface TRSOrder ()

@property (nonatomic, readwrite, copy) NSString *tsID;
@property (nonatomic, readwrite, copy) NSString *apiToken;

@property (nonatomic, readwrite, strong) TRSConsumer *consumer;
@property (nonatomic, readwrite, copy) NSString *ordernr;
@property (nonatomic, readwrite, strong) NSNumber *amount;
@property (nonatomic, readwrite, copy) NSString *curr;
@property (nonatomic, readwrite, copy) NSString *paymentType;

@property (nonatomic, readwrite, assign) TRSOrderState orderState;
@property (nonatomic, readwrite, assign) TRSInsuranceState insuranceState;
@property (nonatomic, readwrite, assign) TRSNextActionFlag nextActionFlag;

@end

@implementation TRSOrder

+ (instancetype)TRSOrderWithTrustedShopsID:(NSString *)trustedShopsID
								  apiToken:(NSString *)apiToken
									 email:(NSString *)email
								   ordernr:(NSString *)orderNo
									amount:(NSNumber *)amount
									  curr:(NSString *)currency
							   paymentType:(NSString *)paymentType
							  deliveryDate:(NSDate *)estDeliveryDate {
	
	return [[TRSOrder alloc] initWithTrustedShopsID:trustedShopsID
										   apiToken:apiToken
											  email:email
											ordernr:orderNo
											 amount:amount
											   curr:currency
										paymentType:paymentType
									   deliveryDate:estDeliveryDate];
}


- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID
							  apiToken:(NSString *)apiToken
								 email:(NSString *)email
							   ordernr:(NSString *)orderNo
								amount:(NSNumber *)amount
								  curr:(NSString *)currency
						   paymentType:(NSString *)paymentType
						  deliveryDate:(NSDate *)estDeliveryDate {
	
	
	self = [super init];
	if (self) {
		TRSConsumer *consumer = [[TRSConsumer alloc] initWithEmail:email];
		if (!consumer) {
			return nil;
		}
		
		self.tsID = trustedShopsID;
		self.apiToken = apiToken;
		self.consumer = consumer;
		self.ordernr = orderNo;
		self.amount = amount;
		self.curr = currency;
		self.paymentType = paymentType;
		self.deliveryDate = estDeliveryDate;
		
		self.insuranceState = TRSInsuranceStateUnknown;
		self.nextActionFlag = TRSValidationPending;
		
		self.orderState = TRSOrderUnprocessed;
		if (![self areFieldsComplete]) return nil;
	}
	return self;
}

- (void)validateWithCompletionBlock:(void (^)(NSError *error))onCompletion {
//	NSLog(@"Order will query the API, for now just fake it! No remote connection will be made");
//	NSLog(@"some internal state changes are made");
	
	// note that we will always set ourselves as "processing", even if the validation fails
	// (i.e. conceptually "validate" is a part of "processing")
	self.orderState &= (~TRSOrderUnprocessed);
	self.orderState |= TRSOrderProcessing;
	
	NSError *error = nil;
	if (![self areFieldsComplete]) {
		error = [NSError errorWithDomain:TRSErrorDomain
									code:TRSErrorDomainProcessOrderInvalidData
								userInfo:@{NSLocalizedDescriptionKey :
											   @"order object invalid or corrupted"}];
	} else {
		self.nextActionFlag = TRSShowWebViewInLightbox;
	}
	onCompletion(error);
}

- (void)finishWithCompletionBlock:(void (^)(NSError *error))onCompletion {
	self.orderState &= (~TRSOrderUnprocessed);
	self.orderState |= TRSOrderProcessing;
	
	TRSCheckoutViewController *checkoutVC = [[TRSCheckoutViewController alloc] initWithNibName:nil bundle:nil];
	[checkoutVC processOrder:self onCompletion:^(BOOL canceled, NSError * _Nullable error) {
		
		if (error) {
			// check state & adapt flags
			[self areFieldsComplete]; // this sets the incomplete flag if needed.
			self.nextActionFlag = TRSValidationPending; // set this back to default
			
			// TODO: construct a better suited error and return that
			if (onCompletion) onCompletion(error);
		} else { // success, so set the flags accordingly!
			self.orderState &= (~TRSOrderProcessing);
			self.orderState |= TRSOrderProcessed;
			
			// TODO: figure out membership status in checkout object & set state there.
			self.consumer.membershipStatus = TRSMemberKnown;
			
			if (canceled) {
				self.insuranceState = TRSUserDeclinedInsurance;
			} else {
				self.insuranceState = TRSInsured;
			}
			
			self.nextActionFlag = TRSNoNextActions;
			
//			NSLog(@"webView was closed with cancel state: %@", canceled ? @"YES" : @"NO");
			if (onCompletion) onCompletion(nil);
		}
	}];
	
}

#pragma mark - Helper methods

- (BOOL)areFieldsComplete {
	if (!self.tsID || !self.apiToken || !self.consumer || !self.ordernr || !self.amount || !self.curr ||
		!self.paymentType || ![self isCurrencyStringValid] || ![self isPaymentTypeValid]) {
		self.orderState |= TRSOrderIncompleteData;
		return NO;
	} else {
		self.orderState &= (~TRSOrderIncompleteData);
		return YES;
	}
}

- (BOOL)isCurrencyStringValid {
	NSArray *valids = @[@"EUR", @"USD", @"AUD", @"CAD", @"CHF", @"DKK", @"GBP", @"JPY", @"NZD", @"SEK", @"PLN",
						@"NOK", @"BGN", @"RON", @"RUB", @"TRY", @"CZK", @"HUF", @"HRK"];
	if ([valids containsObject:self.curr]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isPaymentTypeValid {
	NSArray *valids =  @[@"DIRECT_DEBIT", @"CASH_ON_PICKUP", @"CLICKANDBUY", @"FINANCING", @"GIROPAY",
						 @"GOOGLE_CHECKOUT", @"CREDIT_CARD", @"LEASING", @"MONEYBOOKERS", @"CASH_ON_DELIVERY",
						 @"PAYBOX", @"PAYPAL", @"INVOICE", @"CHEQUE", @"SHOP_CARD", @"DIRECT_E_BANKING", @"T_PAY",
						 @"PREPAYMENT", @"AMAZON_PAYMENTS"];
	if ([valids containsObject:self.paymentType]) {
		return YES;
	} else {
		return NO;
	}
}

@end
