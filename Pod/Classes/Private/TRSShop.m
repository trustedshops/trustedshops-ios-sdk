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
		self.languageISO2 = shopInfo[@"languageISO2"] ? shopInfo[@"languageISO2"] : @"en";
		self.targetMarketISO3 = shopInfo[@"targetMarketISO3"] ? shopInfo[@"targetMarketISO3"] : @"EUO";
		self.tsId = shopInfo[@"tsId"];
		self.url = shopInfo[@"url"];
		self.name = shopInfo[@"name"];
		self.trustMark = [[TRSTrustMark alloc] initWithDictionary:shopInfo[@"trustMark"]];
	}
	return self;
}

@end
