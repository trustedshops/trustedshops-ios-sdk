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
#import "TRSProductReview.h"
#import "TRSCriteria.h"

@implementation TRSNetworkAgent (ProductGrade)

- (NSURLSessionDataTask *)getProductGradeForTrustedShopsID:(NSString *)trustedShopsID
												  apiToken:(NSString *)apiToken
													   SKU:(NSString *)SKU
												   success:(void (^)(NSDictionary *gradeData))success
												   failure:(void (^)(NSError *error))failure {
	
	if (![self didReturnErrorForTSID:trustedShopsID apiToken:apiToken SKU:SKU failureBlock:failure]) {
		
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
		
		return [self GET:[NSURL productGradeAPIURLForTSID:trustedShopsID skuHash:[self hashForSKU:SKU] debug:self.debugMode]
			   authToken:apiToken
				 success:successBlock
				 failure:failureBlock];
	}
	return nil;
}

- (NSURLSessionDataTask *)getProductReviewsForTrustedShopsID:(NSString *)trustedShopsID
													apiToken:(NSString *)apiToken
														 SKU:(NSString *)SKU
													 success:(void (^)(NSArray *reviews))success
													 failure:(void (^)(NSError *error))failure {
	
	if (![self didReturnErrorForTSID:trustedShopsID apiToken:apiToken SKU:SKU failureBlock:failure]) {
		
		void (^successBlock)(NSData *data) = ^(NSData *data) {
			NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
																	 options:kNilOptions
																	   error:nil];
			NSString *uid, *comment, *dateString, *criteriaTypeString, *markString, *critMarkString;
			NSNumber *mark, *criteriaMark;
			NSDate *creationDate;
			TRSCriteria *criteria;
			TRSCriteriaType criteriaType;
			NSArray *actuallyRelevant, *criteriaArray;
			NSDateFormatter *dateFormatter = [NSDateFormatter new];
			dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
			TRSProductReview *oneReview;
			NSMutableArray *results, *myCriteriaArray;
			BOOL invalid = NO;
			@try {
				actuallyRelevant = jsonData[@"response"][@"data"][@"product"][@"reviews"];
				if (actuallyRelevant) {
					results = [[NSMutableArray alloc] initWithCapacity:actuallyRelevant.count];
					for (NSDictionary *iter in actuallyRelevant) {
						uid = iter[@"UID"];
						comment = iter[@"comment"];
						dateString = iter[@"creationDate"];
						creationDate = [dateFormatter dateFromString:dateString];
						markString = iter[@"mark"];
						mark = [NSNumber numberWithFloat:[markString floatValue]];
						criteriaArray = iter[@"criteria"];
						myCriteriaArray = [[NSMutableArray alloc] initWithCapacity:criteriaArray.count];
						for (NSDictionary *crit in criteriaArray) {
							critMarkString = crit[@"mark"];
							criteriaMark = [NSNumber numberWithFloat:[critMarkString floatValue]];
							criteriaTypeString = crit[@"type"];
							criteriaType = [TRSCriteria criteriaTypeFromString:criteriaTypeString];
							criteria = [[TRSCriteria alloc] initWithMark:criteriaMark type:criteriaType];
							[myCriteriaArray addObject:criteria];
						}
						
						oneReview = [[TRSProductReview alloc] initWithCreationDate:creationDate
																		   comment:comment
																			  mark:mark
																			   UID:uid
																		  criteria:[NSArray arrayWithArray:myCriteriaArray]];
						[results addObject:oneReview];
					}
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
			
			if (success) success([NSArray arrayWithArray:results]);
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
		
		return [self GET:[NSURL productReviewAPIURLForTSID:trustedShopsID skuHash:[self hashForSKU:SKU] debug:self.debugMode]
			   authToken:apiToken
				 success:successBlock
				 failure:failureBlock];
	}
	return nil;
}

@end
