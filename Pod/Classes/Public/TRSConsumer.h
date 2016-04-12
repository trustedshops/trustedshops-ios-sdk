//
//  TRSConsumer.h
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import <Foundation/Foundation.h>

/**
 The status a consumer can have at Trusted Shops. It's determined by contacting the remote API.
 */
typedef NS_ENUM(NSUInteger, TRSMembershipStatus) {
	/** The consumer's status is not yet checked against the remote Trusted Shops API */
	TRSMemberUnverified,
	/** The consumer is not known to Trusted Shops and/or he is not a member. */
	TRSMemberUnknown,
	/** The consumer is a regular member at Trusted Shops, i.e. has purchased in a Trusted Shops affiliated shop before.*/
	TRSMemberKnown,
	/** The consumer is a premium member at Trusted Shops, i.e. has purchased in a Trusted Shops affiliated shop before
	 and even purchased an extended guarantee. */
	TRSMemberPremium
};


/**
 `TRSConsumer` represents a (potential) Trusted Shop Consumer member.
 Besides a consumer's email as identification objects of this kind also represent the type of
 membership a consumer has. You probably do not need to create objects of this type yourself, but
 can access them during a purchase process with Trusted Shops to see whether a consumer
 is a Trusted Shops member.
 */
@interface TRSConsumer : NSObject

/** @name Creating a TRSConsumer instance
 */

/**
 The designated intializer.
 
 This method is mainly called by `TRSOrder` when it creates a consumer representation during the purchase process.
 You can create your own `TRSConsumer` objects, but currently there is no way for you to change its 
 `TRSMembershipStatus` outside of the purchase process.
 
 @param email The email address of the consumer. Must not be `nil`.
 @see [TRSOrder initWithTrustedShopsID:apiToken:email:ordernr:amount:curr:paymentType:deliveryDate:]
 */
- (nullable instancetype)initWithEmail:(nonnull NSString *)email NS_DESIGNATED_INITIALIZER;

/**
 The email address of the consumer.
 
 During the purchase process, we use it to identify the consumer in our database. Set on initialiation, can't be `nil`.
 */
@property (nonatomic, readonly, nonnull) NSString *email;
/**
 The membership status the consumer has at Trusted Shops.
 
 Right after intialization this is `TRSMemberUnverified`, as it has not yet been checked with our remote API.
 If the object is the child of a `TRSOrder` object, this property will be updated along the purchase process.
 */
@property (nonatomic, readonly) TRSMembershipStatus membershipStatus;

@end
