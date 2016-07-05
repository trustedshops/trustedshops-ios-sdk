//
//  TRSProductBaseView.m
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSProductBaseView.h"
#import "TRSNetworkAgent+ProductGrade.h"
#import "TRSErrors.h"
#import "TRSPrivateBasicDataView+Private.h" // internally give me access to the private methods of my base view...

NSString *const kTRSProductBaseViewSKUKey = @"kTRSProductBaseViewSKUKey";

@interface TRSProductBaseView ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSNumber *totalReviewCount;
@property (nonatomic, strong) NSNumber *overallMark;
@property (nonatomic, copy) NSString *overallMarkDescription;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation TRSProductBaseView

- (instancetype)initWithFrame:(CGRect)frame trustedShopsID:(NSString *)tsID apiToken:(NSString *)apiToken SKU:(NSString *)SKU {
	self = [super initWithFrame:frame trustedShopsID:tsID apiToken:apiToken];
	if (self) {
		self.SKU = SKU;
	}
	return self;
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

#pragma mark - Methods supposed to be overridden in subclasses (TRSPrivateBasicDataViewLoading protocol)
- (void)finishInit {
	NSLog(@"TRSProductBaseView -finishInit: Nothing to finish, method should be overridden");
}

- (void)setupData:(id)data {
	
}

- (void)finishLoading {
	
}

- (void)performNetworkRequestWithSuccessBlock:(void (^)(id result))successBlock failureBlock:(void(^)(NSError *error))failureBlock {
	[[TRSNetworkAgent sharedAgent] getProductGradeForTrustedShopsID:self.tsID
														   apiToken:self.apiToken
																SKU:self.SKU
															success:successBlock
															failure:failureBlock];
}

@end
