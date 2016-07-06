//
//  TRSNetworkAgent+ProductGrade.m
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSNetworkAgent+ProductGrade.h"
#import "TRSNetworkAgent+Commons.h"
#import "TRSErrors.h"
#import "NSURL+TRSURLExtensions.h"

@implementation TRSNetworkAgent (ProductGrade)

- (NSURLSessionDataTask *)getProductGradeForTrustedShopsID:(NSString *)trustedShopsID
												  apiToken:(NSString *)apiToken
													   SKU:(NSString *)SKU
												   success:(void (^)(NSDictionary *gradeData))success
												   failure:(void (^)(NSError *error))failure {
	
	if (![self didReturnErrorForTSID:trustedShopsID apiToken:apiToken failureBlock:failure]) {
		
		NSString *skuHash = [self hashForSKU:SKU];
		
		if (!skuHash) {
			if (failure) {
				NSError *myError = [NSError errorWithDomain:TRSErrorDomain
													   code:TRSErrorDomainMissingSKU
												   userInfo:nil];
				failure(myError);
			}
			return nil;
		}
		
		void (^successBlock)(NSData *data) = ^(NSData *data) {
			NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
																	 options:kNilOptions
																	   error:nil];
			id sku, name, uuid, totalReviewCount, overallMark, overallMarkDescription;
			NSDictionary *actuallyRelevant;
			BOOL invalid = NO;
			@try {
				actuallyRelevant = jsonData[@"response"][@"data"][@"product"];
				if (actuallyRelevant) {
					sku = actuallyRelevant[@"sku"];
					name = actuallyRelevant[@"name"];
					uuid = actuallyRelevant[@"uuid"];
					totalReviewCount = actuallyRelevant[@"qualityIndicators"][@"reviewIndicator"][@"totalReviewCount"];
					overallMark = actuallyRelevant[@"qualityIndicators"][@"reviewIndicator"][@"overallMark"];
					overallMarkDescription = actuallyRelevant[@"qualityIndicators"][@"reviewIndicator"][@"overallMarkDescription"];
				} else {
					invalid = YES;
				}
			} @catch (NSException *exception) {
				invalid = YES;
			}
			if (invalid) {
				if (failure) {
					NSError *invalidDataError = [NSError errorWithDomain:TRSErrorDomain
																	code:TRSErrorDomainInvalidData
																userInfo:nil];
					failure(invalidDataError);
				}
				return;
			}
			NSDictionary *retVal = @{@"sku" : sku,
									 @"name" : name,
									 @"uuid" : uuid,
									 @"totalReviewCount" : totalReviewCount,
									 @"overallMark" : overallMark,
									 @"overallMarkDescription" : overallMarkDescription};
			
			if (success) success(retVal);
			return;
		};
		
		void (^failureBlock)(NSData *data, NSHTTPURLResponse *response, NSError *error) = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
			if (failure) {
				if (!error) {
					error = [self standardErrorForResponseCode:response.statusCode];
				}
				
				failure(error);
			}
		};
		
		return [self GET:[NSURL productGradeAPIURLForTSID:trustedShopsID skuHash:skuHash debug:self.debugMode]
			   authToken:apiToken
				 success:successBlock
				 failure:failureBlock];
	}
	return nil;
}

// a helper method to create a has from the SKU
- (NSString *)hashForSKU:(NSString *)SKU{
	if (!SKU) {
		return nil;
	}
	const char *inUTF8 = [SKU UTF8String];
	NSMutableString *asHex = [NSMutableString string];
	while (*inUTF8) {
		[asHex appendFormat:@"%02X", *inUTF8++ & 0x00FF];
	}
	return [NSString stringWithString:asHex];
}

@end
