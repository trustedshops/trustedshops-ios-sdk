//
//  TRSConsumer.h
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TRSMembershipStatus) {
	TRSMemberUnverified,
	TRSMemberUnknown,
	TRSMemberKnown,
	TRSMemberPremium
};

@interface TRSConsumer : NSObject

// might become read only in public header in the future...
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) TRSMembershipStatus membershipStatus;

- (instancetype)initWithEmail:(NSString *)email NS_DESIGNATED_INITIALIZER;

@end
