//
//  TRSProduct.m
//  Pods
//
//  Created by Gero Herkenrath on 22/04/16.
//
//

#import "TRSProduct.h"
#import "TRSNetworkAgent+ProductGrade.h"

@interface TRSProduct ()

@property (nonatomic, strong, readwrite, nullable) NSArray *reviews;

@end

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

- (void)loadReviewsFromBackendWithTrustedShopsID:(NSString *)tsID
										apiToken:(NSString *)apiToken
									successBlock:(nullable void (^)(void))success
									failureBlock:(nullable void (^)(NSError *_Nullable error))failure {
	
	[TRSNetworkAgent sharedAgent].debugMode = self.debugMode;
	[[TRSNetworkAgent sharedAgent] getProductReviewsForTrustedShopsID:tsID apiToken:apiToken SKU:self.SKU success:^(NSArray *reviews) {
		self.reviews = reviews;
		if (success) {
			success();
		}
	} failure:failure];
}

@end
