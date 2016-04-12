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

@property (nonatomic, readonly) NSString *tsID;
@property (nonatomic, readonly) NSString *apiToken;

@property (nonatomic, readonly) TRSConsumer *consumer;
@property (nonatomic, readonly) NSString *ordernr;
@property (nonatomic, readonly) NSNumber *amount;
@property (nonatomic, readonly) NSString *curr;
@property (nonatomic, readonly) NSString *paymentType;
@property (nonatomic, readonly) NSDate *deliveryDate;
// last one will be fleshed out later...
@property (nonatomic, strong) NSDictionary *tsCheckoutProductItems; // for now. will probably be changed to custom class

@property (nonatomic, readonly) TRSOrderState orderState;
@property (nonatomic, readonly) TRSInsuranceState insuranceState;
@property (nonatomic, readonly) TRSNextActionFlag nextActionFlag;

- (instancetype)initWithTrustedShopsID:(NSString *)trustedShopsID
							  apiToken:(NSString *)apiToken
								 email:(NSString *)email
							   ordernr:(NSString *)orderNo
								amount:(NSNumber *)amount
								  curr:(NSString *)currency
						   paymentType:(NSString *)paymentType
						  deliveryDate:(NSDate *)estDeliveryDate NS_DESIGNATED_INITIALIZER;

- (void)validateWithCompletionBlock:(void (^)(NSError *error))answer;
- (void)finishWithCompletionBlock:(void (^)(NSError *error))failure;
- (void)validateAndFinishWithCompletionBlock:(void (^)(NSError *error))onCompletion;

+ (instancetype)TRSOrderWithTrustedShopsID:(NSString *)trustedShopsID
								  apiToken:(NSString *)apiToken
									 email:(NSString *)email
								   ordernr:(NSString *)orderNo
									amount:(NSNumber *)amount
									  curr:(NSString *)currency
							   paymentType:(NSString *)paymentType
							  deliveryDate:(NSDate *)estDeliveryDate;

@end
