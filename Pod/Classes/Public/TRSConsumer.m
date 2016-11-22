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
		if (email && ![self isValidEmail:email]) {
			return nil;
		}
		_email = email;
		_membershipStatus = TRSMemberUnverified;
	}
	return self;
}

// Note: This is just a VERY simple validation... I won't go full RFC on it...
- (BOOL)isValidEmail:(nonnull NSString *)email {
	if ([email containsString:@"@"]) { // does it have an @ in it?
		NSMutableArray *delimited = [[email componentsSeparatedByString:@"@"] mutableCopy];
		if (![[delimited lastObject] containsString:@"."]) { // a delimiter for the toplevel domain?
			return NO;
		}
		[delimited removeLastObject];
		NSString *front = [delimited componentsJoinedByString:@"@"];
		if ([front length] > 0) {
			return YES;
		}
	}
	return NO;
}

@end
