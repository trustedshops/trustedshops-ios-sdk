//
//  TRSProduct.m
//  Pods
//
//  Created by Gero Herkenrath on 22/04/16.
//
//

#import "TRSProduct.h"

@implementation TRSProduct

- (nullable instancetype)initWithUrl:(nonnull NSURL *)url
							   name:(nonnull NSString *)name
								SKU:(nonnull NSString *)SKU {
	
	self = [super init];
	if (self) {
		if ([name isEqualToString:@""] || [SKU isEqualToString:@""]) {
			return nil;
		}
		self.url = url;
		self.name = name;
		self.SKU = SKU;
	}
	return self;
}

- (nonnull NSString *)jsStringDescription {
	NSString *tempImageUrl = self.imageUrl ? [self.imageUrl absoluteString] : @"NULL";
	NSString *tempGTIN = self.GTIN ? self.GTIN : @"NULL";
	NSString *tempMPN = self.MPN ? self.MPN : @"NULL";
	NSString *tempBrand = self.brand ? self.brand : @"NULL";
	
	return [NSString stringWithFormat:@"'%@', '%@', '%@', '%@', '%@', '%@', '%@'", [self.url absoluteString],
			self.name, self.SKU, tempImageUrl, tempGTIN, tempMPN, tempBrand];
}

@end
