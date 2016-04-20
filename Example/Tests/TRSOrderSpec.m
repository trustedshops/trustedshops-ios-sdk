#import "TRSOrder.h"
#import "TRSConsumer.h"
#import <Specta/Specta.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>

// import the private interface for tests
@interface TRSOrder (PrivateTests)

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

- (BOOL)areFieldsComplete;

@end


SpecBegin(TRSOrder)

describe(@"TRSOrder", ^{
	
	__block NSDictionary *exampleFields; // these hold sample values used over all the tests
	beforeAll(^{
		exampleFields = @{@"trustedShopsID" : @"X330A2E7D449E31E467D2F53A55DDD070",
						  @"apiToken" : @"notneededatm",
						  @"email" : @"a@bc.de",
						  @"orderNo" : @"37AD9412",
						  @"amount" : [NSNumber numberWithDouble:24.99],
						  @"currency" : @"EUR",
						  @"paymentType" : @"CREDIT_CARD",
						  @"estDeliveryDate" : [NSDate date],
						  
						  @"badTrustedShopsID" : @"X330A2E7D449E31E467D2F5tooshort",
						  @"badEmail" : @"notanemail",
						  @"badCurrency" : @"BLOOD",
						  @"badPaymentType" : @"WHENHELLFREEZES"
						  };
	});
	afterAll(^{
		exampleFields = nil;
	});
	
	describe(@"property setters", ^{
		
		it(@"allows setting properties after initialization", ^{
			TRSOrder *aTestOrder = [TRSOrder TRSOrderWithTrustedShopsID:exampleFields[@"trustedShopsID"]
															   apiToken:exampleFields[@"apiToken"]
																  email:exampleFields[@"email"]
																ordernr:exampleFields[@"orderNo"]
																 amount:exampleFields[@"amount"]
																   curr:exampleFields[@"currency"]
															paymentType:exampleFields[@"paymentType"]
														   deliveryDate:exampleFields[@"estDeliveryDate"]];
			aTestOrder.tsID = @"changed";
			expect(aTestOrder.tsID).to.equal(@"changed");
			aTestOrder.apiToken = @"changed";
			expect(aTestOrder.apiToken).to.equal(@"changed");
			TRSConsumer *testConsumer = [[TRSConsumer alloc] initWithEmail:@"changed@bc.de"];
			aTestOrder.consumer = testConsumer;
			expect(aTestOrder.consumer).to.equal(testConsumer);
			aTestOrder.ordernr = @"changed";
			expect(aTestOrder.ordernr).to.equal(@"changed");
			NSNumber *newAmount = [NSNumber numberWithDouble:499.99];
			aTestOrder.amount = newAmount;
			expect(aTestOrder.amount).to.equal(newAmount);
			aTestOrder.curr = @"changed";
			expect(aTestOrder.curr).to.equal(@"changed");
			aTestOrder.paymentType = @"changed";
			expect(aTestOrder.paymentType).to.equal(@"changed");
			NSDate *newDate = [NSDate dateWithTimeIntervalSinceNow:60.0 * 60.0];
			aTestOrder.deliveryDate = newDate;
			expect(aTestOrder.deliveryDate).to.equal(newDate);
			aTestOrder.orderState = NSUIntegerMax; // not a meaningful state, but good for test
			expect(aTestOrder.orderState).to.equal(NSUIntegerMax);
			aTestOrder.insuranceState = NSUIntegerMax;
			expect(aTestOrder.insuranceState).to.equal(NSUIntegerMax);
			aTestOrder.nextActionFlag = NSUIntegerMax;
			expect(aTestOrder.nextActionFlag).to.equal(NSUIntegerMax);
		});
		
	});
	
	describe(@"+TRSOrderWithTrustedShopsID:apiToken:email:ordernr:amount:curr:paymentType:deliveryDate:", ^{
		
		it(@"calls initWithTrustedShopsID:apiToken:email:ordernr:amount:curr:paymentType:deliveryDate:", ^{
			id mockOrder = OCMClassMock([TRSOrder class]);
			OCMStub([mockOrder initWithTrustedShopsID:exampleFields[@"trustedShopsID"]
											 apiToken:exampleFields[@"apiToken"]
												email:exampleFields[@"email"]
											  ordernr:exampleFields[@"orderNo"]
											   amount:exampleFields[@"amount"]
												 curr:exampleFields[@"currency"]
										  paymentType:exampleFields[@"paymentType"]
										 deliveryDate:exampleFields[@"estDeliveryDate"]]).andReturn(nil);
			TRSOrder *aTestOrder = [TRSOrder TRSOrderWithTrustedShopsID:exampleFields[@"trustedShopsID"]
															   apiToken:exampleFields[@"apiToken"]
																  email:exampleFields[@"email"]
																ordernr:exampleFields[@"orderNo"]
																 amount:exampleFields[@"amount"]
																   curr:exampleFields[@"currency"]
															paymentType:exampleFields[@"paymentType"]
														   deliveryDate:exampleFields[@"estDeliveryDate"]];
			OCMVerifyAll(mockOrder);
			aTestOrder = nil;
			mockOrder = nil;
		});
		
	});
	
	describe(@"-initWithTrustedShopsID:apiToken:email:ordernr:amount:curr:paymentType:deliveryDate:", ^{
		
		context(@"with valid parameters", ^{
			
			__block TRSOrder *aTestOrder;
			beforeAll(^{
				aTestOrder = [[TRSOrder alloc] initWithTrustedShopsID:exampleFields[@"trustedShopsID"]
															 apiToken:exampleFields[@"apiToken"]
																email:exampleFields[@"email"]
															  ordernr:exampleFields[@"orderNo"]
															   amount:exampleFields[@"amount"]
																 curr:exampleFields[@"currency"]
														  paymentType:exampleFields[@"paymentType"]
														 deliveryDate:nil]; // tested a date above already
			});
			afterAll(^{
				aTestOrder = nil;
			});
			
			it(@"has a consumer property with the correct email", ^{
				expect(aTestOrder.consumer.email).to.equal(exampleFields[@"email"]);
			});
			
			it(@"sets all required atomic properties correctly", ^{
				expect(aTestOrder.tsID).to.equal(exampleFields[@"trustedShopsID"]);
				expect(aTestOrder.apiToken).to.equal(exampleFields[@"apiToken"]);
				expect(aTestOrder.ordernr).to.equal(exampleFields[@"orderNo"]);
				expect(aTestOrder.amount).to.equal(exampleFields[@"amount"]);
				expect(aTestOrder.curr).to.equal(exampleFields[@"currency"]);
				expect(aTestOrder.paymentType).to.equal(exampleFields[@"paymentType"]);
				expect(aTestOrder.deliveryDate).to.beNil(); // as was set in the init above!
			});
			
			it(@"has a correct initial order state", ^{
				expect(aTestOrder.orderState & TRSOrderUnprocessed).to.equal(TRSOrderUnprocessed);
				expect(aTestOrder.orderState & TRSOrderProcessing).toNot.equal(TRSOrderProcessing);
				expect(aTestOrder.orderState & TRSOrderIncompleteData).toNot.equal(TRSOrderIncompleteData);
				expect(aTestOrder.orderState & TRSOrderProcessed).toNot.equal(TRSOrderProcessed);
				expect(aTestOrder.orderState & TRSOrderBillBelowThreshold).toNot.equal(TRSOrderBillBelowThreshold);
				expect(aTestOrder.orderState & TRSOrderBillAboveThreshold).toNot.equal(TRSOrderBillAboveThreshold);
			});
			
			it(@"has a correct initial insuranceState", ^{
				expect(aTestOrder.insuranceState & TRSInsuranceStateUnknown).to.equal(TRSInsuranceStateUnknown);
				expect(aTestOrder.insuranceState & TRSNotInsured).toNot.equal(TRSNotInsured);
				expect(aTestOrder.insuranceState & TRSPartiallyInsured).toNot.equal(TRSPartiallyInsured);
				expect(aTestOrder.insuranceState & TRSFullyInsured).toNot.equal(TRSFullyInsured);
			});
			
			it(@"has a correct initial nextActionFlag", ^{
				expect(aTestOrder.nextActionFlag & TRSValidationPending).to.equal(TRSValidationPending);
				expect(aTestOrder.nextActionFlag & TRSNoNextActions).toNot.equal(TRSNoNextActions);
				expect(aTestOrder.nextActionFlag & TRSShowWebViewInLightbox).toNot.equal(TRSShowWebViewInLightbox);
				expect(aTestOrder.nextActionFlag & TRSShowExistingInsurance).toNot.equal(TRSShowExistingInsurance);
				expect(aTestOrder.nextActionFlag & TRSRecommendUpgradeInWebView).toNot.equal(TRSRecommendUpgradeInWebView);
				expect(aTestOrder.nextActionFlag & TRSShowUpgradeInComingEmail).toNot.equal(TRSShowUpgradeInComingEmail);
			});
			
			it(@"calls areFieldComplete", ^{
				// note: I "re-init" the object here, because OCMock is kinda stupid otherwise.
				id partialMock = OCMPartialMock(aTestOrder);
				id notUsed = [aTestOrder initWithTrustedShopsID:exampleFields[@"trustedShopsID"]
													   apiToken:exampleFields[@"apiToken"]
														  email:exampleFields[@"email"]
														ordernr:exampleFields[@"orderNo"]
														 amount:exampleFields[@"amount"]
														   curr:exampleFields[@"currency"]
													paymentType:exampleFields[@"paymentType"]
												   deliveryDate:nil];
				OCMVerify([partialMock areFieldsComplete]);
				notUsed = nil;
			});
			
		});
		
	});
	
	context(@"validation and API calls with a valid and new order", ^{
		
		__block TRSOrder *aTestOrder;
		beforeEach(^{
			aTestOrder = [[TRSOrder alloc] initWithTrustedShopsID:exampleFields[@"trustedShopsID"]
														 apiToken:exampleFields[@"apiToken"]
															email:exampleFields[@"email"]
														  ordernr:exampleFields[@"orderNo"]
														   amount:exampleFields[@"amount"]
															 curr:exampleFields[@"currency"]
													  paymentType:exampleFields[@"paymentType"]
													 deliveryDate:nil];
		});
		afterEach(^{
			aTestOrder = nil;
		});
		
		describe(@"-validateWithCompletionBlock:", ^{
			
			it(@"calls the completion block", ^{
				waitUntil(^(DoneCallback done) {
					[aTestOrder validateWithCompletionBlock:^(NSError * _Nullable error) {
						done();
					}];
				});
			});
			
		});
		
		describe(@"-finishWithCompletionBlock:", ^{
			
			// This test requires user interaction (to press the OK button) and thus needs to be reworked a lot.
			// TODO: Stub presentViewController:animated:completion: or something and instead call completion handler.
//			it(@"calls the completion block", ^{ // rename this!
//				waitUntil(^(DoneCallback done) {
//					[aTestOrder finishWithCompletionBlock:^(NSError * _Nullable error) {
//						done();
//					}];
//				});
//			});
			
			it(@"displays a modal view", ^{
				id rootVCMock = OCMPartialMock([[[UIApplication sharedApplication] keyWindow] rootViewController]);
				OCMStub([rootVCMock presentViewController:[OCMArg any] animated:YES completion:nil]);
				[aTestOrder finishWithCompletionBlock:nil];
				OCMVerify([rootVCMock presentViewController:[OCMArg any] animated:YES completion:nil]);
			});
			
		});
		
	});
	
	describe(@"-areFieldsComplete", ^{
		
		__block TRSOrder *aTestOrder;
		beforeAll(^{
			aTestOrder = [[TRSOrder alloc] initWithTrustedShopsID:exampleFields[@"trustedShopsID"]
														 apiToken:exampleFields[@"apiToken"]
															email:exampleFields[@"email"]
														  ordernr:exampleFields[@"orderNo"]
														   amount:exampleFields[@"amount"]
															 curr:exampleFields[@"currency"]
													  paymentType:exampleFields[@"paymentType"]
													 deliveryDate:nil];
		});
		afterAll(^{
			aTestOrder = nil;
		});
		
		context(@"with a correctly initialized order", ^{
			
			it(@"returns YES", ^{
				expect([aTestOrder areFieldsComplete]).to.equal(YES);
			});
			
			it(@"unmasks the TRSOrderIncomplete bit in the orderState", ^{
				aTestOrder.orderState |= TRSOrderIncompleteData;
				[aTestOrder areFieldsComplete];
				expect(aTestOrder.orderState & TRSOrderIncompleteData).toNot.equal(TRSOrderIncompleteData);
			});
			
		});
		
		context(@"with an order with incomplete data", ^{
			
			beforeAll(^{
				aTestOrder.tsID = nil;
				aTestOrder.apiToken = nil;
				aTestOrder.consumer = nil;
				aTestOrder.ordernr = nil;
				aTestOrder.amount = nil;
				aTestOrder.curr = nil;
				aTestOrder.paymentType = nil;
			});
			
			it(@"returns NO", ^{
				expect([aTestOrder areFieldsComplete]).to.equal(NO);
			});
			
			it(@"sets the TRSOrderIncomplete bit in the orderState", ^{
				aTestOrder.orderState &= (~TRSOrderIncompleteData);
				[aTestOrder areFieldsComplete];
				expect(aTestOrder.orderState & TRSOrderIncompleteData).to.equal(TRSOrderIncompleteData);
			});
			
		});
		
	});
	
});

SpecEnd
