//
//  TRSOrder.m
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import "TRSOrder.h"

@implementation TRSOrder

- (instancetype)init
{
	return [self initWithTrustedShopsID:nil
							   apiToken:nil
								  email:nil
								ordernr:nil
								 amount:nil
								   curr:nil
							paymentType:nil
						   deliveryDate:nil];
}

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
		
		self.orderState = TRSOrderUnprocessed;
		[self areFieldsComplete];
	}
	return self;
}

- (void)queryAPIWithAnswerBlock:(void (^)(NSError *error))answer {
	NSLog(@"Order will query the API, for now just fake it! No remote connection will be made");
	NSLog(@"some internal state changes are made");
	if ([self areFieldsComplete]) {
		self.orderState &= (~TRSOrderUnprocessed);
		self.orderState |= TRSOrderProcessing | TRSOrderBillBelowThreshold;
	}
	answer(nil);
}

- (void)finishOrderWithFailureBlock:(void (^)(NSError *error))failure {
	NSLog(@"Order will finish by accessing the API, for now just fake it! No remote connection will be made");
	NSLog(@"Order changes internal states and displays a UI element");
	
	if (![self areFieldsComplete]) {
		NSError *retError = [NSError errorWithDomain:@"ordererror" code:999 userInfo:nil];
		failure(retError);
	}
	
	NSString *alertMsg = @"This will display some sort of lightbox with a webview in the future!.";
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Future WebView"
																   message:alertMsg
															preferredStyle:UIAlertControllerStyleAlert];
 
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
															  failure(nil);
														  }];
 
	[alert addAction:defaultAction];
	[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
	self.orderState &= (~TRSOrderProcessing);
	self.orderState |= TRSOrderProcessed;
}

- (void)queryAPIAndFinishOrderWithCompletionBlock:(void (^)(NSError *error))onCompletion {
	NSLog(@"Query & immediately finish if query is okay. JUST FAKED FOR NOW, no remote connection will be made");
}

#pragma mark - Helper methods

- (BOOL)areFieldsComplete {
	// TODO: check if some of these are optional
	if (!self.tsID || !self.apiToken || !self.consumer || !self.ordernr ||
		!self.amount || !self.curr || !self.paymentType || !self.deliveryDate) {
		self.orderState |= TRSOrderIncompleteData;
		return NO;
	} else {
		self.orderState &= (~TRSOrderIncompleteData);
		return YES;
	}
}

@end
