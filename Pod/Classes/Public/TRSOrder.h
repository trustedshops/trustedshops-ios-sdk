//
//  TRSOrder.h
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import <Foundation/Foundation.h>
#import "TRSConsumer.h"

typedef NS_OPTIONS(NSUInteger, TRSOrderState) {
	TRSOrderUnprocessed = (1 << 0),
	TRSOrderProcessing = (1 << 1),
	TRSOrderIncompleteData = (1 << 2),
	TRSOrderProcessed = (1 << 3),
	TRSOrderBillBelowThreshold = (1 << 4),
	TRSOrderBillAboveThreshold = (1 << 5)
};

typedef NS_ENUM(NSUInteger, TRSInsuranceState) {
	TRSUnknown,
	TRSNotInsured,
	TRSPartiallyInsured,
	TRSFullyInsured
};

typedef NS_ENUM(NSUInteger, TRSNextActionFlag) {
	TRSNoNextActions,
	TRSQueryFromAPI,
	TRSShowExistingInsurance,
	TRSRecommendUpgrageInWebView,
	TRSShowUpgradeInComingEmail
};

@interface TRSOrder : NSObject

@property (nonatomic, copy) NSString *tsID;
@property (nonatomic, copy) NSString *apiToken;

@property (nonatomic, strong) TRSConsumer *consumer;
@property (nonatomic, copy) NSString *ordernr;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, copy) NSString *curr;
@property (nonatomic, copy) NSString *paymentType;
@property (nonatomic, strong) NSDate *deliveryDate;
// last one will be fleshed out later...
@property (nonatomic, strong) NSDictionary *tsCheckoutProductItems; // for now, will probably changed to custom class

@property (nonatomic, assign) TRSOrderState orderState;
@property (nonatomic, assign) TRSInsuranceState insuranceState;
@property (nonatomic, assign) TRSNextActionFlag nextActionFlag;

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID
							  apiToken:(NSString *)apiToken
								 email:(NSString *)email
							   ordernr:(NSString *)orderNo
								amount:(NSNumber *)amount
								  curr:(NSString *)currency
						   paymentType:(NSString *)paymentType
						  deliveryDate:(NSDate *)estDeliveryDate NS_DESIGNATED_INITIALIZER;

- (void)queryAPIWithAnswerBlock:(void (^)(NSError *error))answer;
- (void)finishOrderWithFailureBlock:(void (^)(NSError *error))failure;
- (void)queryAPIAndFinishOrderWithCompletionBlock:(void (^)(NSError *error))onCompletion;

+ (instancetype)TRSOrderWithTrustedShopsID:(NSString *)trustedShopsID
								  apiToken:(NSString *)apiToken
									 email:(NSString *)email
								   ordernr:(NSString *)orderNo
									amount:(NSNumber *)amount
									  curr:(NSString *)currency
							   paymentType:(NSString *)paymentType
							  deliveryDate:(NSDate *)estDeliveryDate;

@end
