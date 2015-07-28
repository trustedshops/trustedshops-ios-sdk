#import "TRSNetworkAgent.h"

/**
 *  `TRSNetworkAgent+Trustbadge` is a category of `TRSNetworkAgent` to handle network requests for Trustbadge.
 */
@interface TRSNetworkAgent (Trustbadge)

/**
 *  @name Making Trustbadge Requests
 */

/**
 *  Creates and runs a request to fetch Trustbadge
 *
 *  @param trustedShopsID Trusted Shops ID for the shop
 *  @param success        A block object which will be executed when request finishes successfully. The block has a data argument.
 *  @param failure        A block object which will be executed when request finishes unsuccessfully. The block has an error argument.
 *
 *  @return Initialized `NSURLSessionDataTask` object
 */
- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID success:(void (^)(id trustbadge))success failure:(void (^)(NSError *error))failure;

@end
