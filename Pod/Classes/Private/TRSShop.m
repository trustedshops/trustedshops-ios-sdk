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
	self = [super init];
	if (self) {
		self.languageISO2 = @"en";
		self.targetMarketISO3 = @"EUO";
	}
	return self;
}

@end
