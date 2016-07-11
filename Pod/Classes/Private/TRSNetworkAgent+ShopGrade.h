//
//  TRSNetworkAgent+ShopGrade.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSNetworkAgent.h"

@interface TRSNetworkAgent (ShopGrade)

- (NSURLSessionDataTask *)getShopGradeForTrustedShopsID:(NSString *)trustedShopsID
											   apiToken:(NSString *)apiToken
												success:(void (^)(NSDictionary *gradeData))success
												failure:(void (^)(NSError *error))failure;

@end
