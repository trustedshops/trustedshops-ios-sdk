//
//  TRSConsumer.m
//  Pods
//
//  Created by Gero Herkenrath on 11/04/16.
//
//

#import "TRSConsumer.h"
#import "TRSConsumer+Private.h"

@implementation TRSConsumer

- (instancetype)init
{
	return [self initWithEmail:@""];
}

- (instancetype)initWithEmail:(NSString *)email {
	self = [super init];
	if (self) {
		if (![self isValidEmail:email]) {
			return nil;
		}
		self.email = email;
		self.membershipStatus = TRSMemberUnverified;
	}
	return self;
}

// Note: This is just a VERY simple validation... I won't go full RFC on it...
- (BOOL)isValidEmail:(nonnull NSString *)email {
	if ([email containsString:@"@"]) { // does it have an @ in it?
		if ([[[email componentsSeparatedByString:@"@"] lastObject] containsString:@"."]) { // a delimiter for the toplevel domain?
			return YES;
		}
	}
	return NO;
}

@end
