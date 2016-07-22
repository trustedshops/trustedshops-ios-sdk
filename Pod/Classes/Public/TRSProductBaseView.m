//
//  TRSProductBaseView.m
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSProductBaseView.h"
#import "TRSProductBaseView+Private.h"
#import "TRSNetworkAgent+ProductGrade.h"
#import "TRSErrors.h"
#import "NSString+TRSStringOperations.h"
#import "TRSPrivateBasicDataView+Private.h" // internally give me access to the private methods of my base view...

NSString *const kTRSProductBaseViewSKUKey = @"kTRSProductBaseViewSKUKey";

// the class extension is in TRSProductBaseView+Private.h !

@implementation TRSProductBaseView

- (instancetype)initWithFrame:(CGRect)frame trustedShopsID:(NSString *)tsID apiToken:(NSString *)apiToken SKU:(NSString *)SKU {
	self = [super initWithFrame:frame trustedShopsID:tsID apiToken:apiToken];
	if (self) {
		self.SKU = SKU;
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame trustedShopsID:(NSString *)tsID apiToken:(NSString *)apiToken {
	return [self initWithFrame:frame trustedShopsID:tsID apiToken:apiToken SKU:nil];
}

// override this as needed, but be aware that super calls finishInit before the properties are decoded!
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.SKU = [aDecoder decodeObjectForKey:kTRSProductBaseViewSKUKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.SKU forKey:kTRSProductBaseViewSKUKey];
}

#pragma mark - Methods supposed to be overridden in subclasses (TRSPrivateBasicDataView+Private header)
- (void)finishInit {
	NSLog(@"TRSProductBaseView -finishInit: Nothing to finish, method should be overridden");
}

- (BOOL)setupData:(id)data {
	// I know that the ProductGrade category on TRSNetworkAgent returns an NSDictionary, so:
	NSDictionary *myData = (NSDictionary *)data;
	
	if ([self.SKU isEqualToString:myData[@"sku"]]) {
		self.name = myData[@"name"];
		self.uuid = myData[@"uuid"];
		self.totalReviewCount = myData[@"totalReviewCount"];
		self.overallMark = myData[@"overallMark"];
		self.overallMarkDescription = [myData[@"overallMarkDescription"] readableMarkDescription];
	} else {
		NSLog(@"data setup failed - returned SKU doesn't match");
		return NO;
	}
	return YES;
}

- (void)finishLoading {
	NSLog(@"TRSProductBaseView -finishLoading: Nothing to finish, method should be overridden");
}

- (void)performNetworkRequestWithSuccessBlock:(void (^)(id result))successBlock failureBlock:(void(^)(NSError *error))failureBlock {
	[[TRSNetworkAgent sharedAgent] getProductGradeForTrustedShopsID:self.tsID
														   apiToken:self.apiToken
																SKU:self.SKU
															success:successBlock
															failure:failureBlock];
}

@end
