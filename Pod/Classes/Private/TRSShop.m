//
//  TRSShop.m
//  Pods
//
//  Created by Gero Herkenrath on 08.03.16.
//
//

#import "TRSShop.h"

@implementation TRSShop

- (instancetype)init
{
	return [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)shopInfo {
	self = [super init];
	if (self) {
		// ensure we have a valid shop Info dictionary:
		NSArray *validKeys = @[@"languageISO2", @"targetMarketISO3", @"tsId", @"url", @"name", @"trustMark"];
		if (!([[NSSet setWithArray:validKeys] isEqualToSet:[NSSet setWithArray:[shopInfo allKeys]]])) {
			self = nil;
			return self;
		}
		
		self.trustMark = [[TRSTrustMark alloc] initWithDictionary:shopInfo[@"trustMark"]];
		if (!_trustMark) {
			self = nil;
			return self;
		}

		self.languageISO2 = shopInfo[@"languageISO2"] ? shopInfo[@"languageISO2"] : @"en";
		self.targetMarketISO3 = shopInfo[@"targetMarketISO3"] ? shopInfo[@"targetMarketISO3"] : @"EUO";
		self.tsId = shopInfo[@"tsId"];
		self.url = shopInfo[@"url"];
		self.name = shopInfo[@"name"];
	}
	return self;
}

@end
