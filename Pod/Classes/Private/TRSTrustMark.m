//
//  TRSTrustMark.m
//  Pods
//
//  Created by Gero Herkenrath on 08.03.16.
//
//

#import "TRSTrustMark.h"

@implementation TRSTrustMark

- (instancetype)init
{
	return [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)trustMarkInfo {
	self = [super init];
	if (self) {
		self.status = trustMarkInfo[@"status"] ? trustMarkInfo[@"status"] : @"INVALID"; // TODO: check possible values
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
		if (trustMarkInfo[@"validFrom"]) {
			self.validFrom = [dateFormatter dateFromString:trustMarkInfo[@"validFrom"]];
		}
		if (trustMarkInfo[@"validTo"]) {
			self.validTo = [dateFormatter dateFromString:trustMarkInfo[@"validTo"]];
		}
	}
	return self;
}

@end
