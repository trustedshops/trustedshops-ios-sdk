//
//  TRSNetworkAgent+ShopGrade.m
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSNetworkAgent+ShopGrade.h"
#import "TRSErrors.h"
#import "TRSNetworkAgent+Commons.h"
#import "NSURL+TRSURLExtensions.h"
#import "NSString+TRSStringOperations.h"

@implementation TRSNetworkAgent (ShopGrade)

- (NSURLSessionDataTask *)getShopGradeForTrustedShopsID:(NSString *)trustedShopsID
											   apiToken:(NSString *)apiToken
												success:(void (^)(NSDictionary *gradeData))success
												failure:(void (^)(NSError *error))failure {
	
	if (![self didReturnErrorForTSID:trustedShopsID apiToken:apiToken failureBlock:failure]) {
	
		void (^successBlock)(NSData *data) = ^(NSData *data) {
			NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
																	 options:kNilOptions
																	   error:nil];
			id markDesc, mark, revCount, targetMarket, language;
			NSDictionary *actuallyRelevant, *retVal;
			BOOL invalid = NO;
			@try {
				actuallyRelevant = jsonData[@"response"][@"data"][@"shop"];
				if (actuallyRelevant) {
					markDesc = actuallyRelevant[@"qualityIndicators"][@"reviewIndicator"][@"overallMarkDescription"];
					mark = actuallyRelevant[@"qualityIndicators"][@"reviewIndicator"][@"overallMark"];
					revCount = actuallyRelevant[@"qualityIndicators"][@"reviewIndicator"][@"activeReviewCount"];
					targetMarket = actuallyRelevant[@"targetMarketISO3"];
					language = actuallyRelevant[@"languageISO2"];
					retVal = @{@"overallMarkDescription" : markDesc ? markDesc : kTRSTechnicalMarkNA,
							   @"overallMark" : mark,
							   @"activeReviewCount" : revCount,
							   @"targetMarketISO3" : targetMarket,
							   @"languageISO2" : language};
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
		
		return [self GET:[NSURL shopGradeAPIURLForTSID:trustedShopsID debug:self.debugMode]
			   authToken:apiToken
				 success:successBlock
				 failure:failureBlock];
	}
	return nil;
}

@end
