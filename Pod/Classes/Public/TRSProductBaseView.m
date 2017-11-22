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
NSString *const kTRSProductBaseViewNameKey = @"kTRSProductBaseViewNameKey";
NSString *const kTRSProductBaseViewUuidKey = @"kTRSProductBaseViewUuidKey";
NSString *const kTRSProductBaseViewTotalReviewCountKey = @"kTRSProductBaseViewTotalReviewCountKey";
NSString *const kTRSProductBaseViewOverallMarkKey = @"kTRSProductBaseViewOverallMarkKey";
NSString *const kTRSProductBaseViewOverallMarkDescriptionKey = @"kTRSProductBaseViewOverallMarkDescriptionKey";

// the class extension making the properties to be loaded writeable is in TRSProductBaseView+Private.h,
// also TRSPrivateBasicDataView+Private.h contains the private methods required for the view loading mechanism to work.

@implementation TRSProductBaseView

- (instancetype)initWithFrame:(CGRect)frame trustedShopsID:(NSString *)tsID apiToken:(NSString *)apiToken SKU:(NSString *)SKU {
	self = [super initWithFrame:frame trustedShopsID:tsID apiToken:apiToken];
	if (self) {
		_SKU = SKU;
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
		_SKU = [aDecoder decodeObjectForKey:kTRSProductBaseViewSKUKey];
		_name = [aDecoder decodeObjectForKey:kTRSProductBaseViewNameKey];
		_uuid = [aDecoder decodeObjectForKey:kTRSProductBaseViewUuidKey];
		_totalReviewCount = [aDecoder decodeObjectForKey:kTRSProductBaseViewTotalReviewCountKey];
		_overallMark = [aDecoder decodeObjectForKey:kTRSProductBaseViewOverallMarkKey];
		_overallMarkDescription = [aDecoder decodeObjectForKey:kTRSProductBaseViewOverallMarkDescriptionKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.SKU forKey:kTRSProductBaseViewSKUKey];
	[aCoder encodeObject:self.name forKey:kTRSProductBaseViewNameKey];
	[aCoder encodeObject:self.uuid forKey:kTRSProductBaseViewUuidKey];
	[aCoder encodeObject:self.totalReviewCount forKey:kTRSProductBaseViewTotalReviewCountKey];
	[aCoder encodeObject:self.overallMark forKey:kTRSProductBaseViewOverallMarkKey];
	[aCoder encodeObject:self.overallMarkDescription forKey:kTRSProductBaseViewOverallMarkDescriptionKey];
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
