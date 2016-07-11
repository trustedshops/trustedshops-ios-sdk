//
//  TRSNetworkAgent+ProductGrade.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSNetworkAgent.h"

@interface TRSNetworkAgent (ProductGrade)

- (NSURLSessionDataTask *)getProductGradeForTrustedShopsID:(NSString *)trustedShopsID
												  apiToken:(NSString *)apiToken
													   SKU:(NSString *)SKU
												   success:(void (^)(NSDictionary *gradeData))success
												   failure:(void (^)(NSError *error))failure;

@end
