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

@end
