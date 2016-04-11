//
//  TRSConsumer.m
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import "TRSConsumer.h"

@implementation TRSConsumer

- (instancetype)init
{
	return [self initWithEmail:nil];
}

- (instancetype)initWithEmail:(NSString *)email {
	self = [super init];
	if (self) {
		self.email = email;
		self.membershipStatus = TRSMemberUnverified;
	}
	return self;
}

@end
