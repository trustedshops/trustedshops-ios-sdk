#import "TRSNetworkAgent.h"

@class TRSTrustbadge;

/**
 *	`TRSNetworkAgent+Trustbadge` is a category of `TRSNetworkAgent` to handle network requests for Trustbadge.
 */
@interface TRSNetworkAgent (Trustbadge)

/**
 *  @name Making Trustbadge Requests
 */

/**
 *	Creates and runs a request to fetch Trustbadge
 *
 *	@param trustedShopsID Trusted Shops ID for the shop
 *	@param apiToken The token required to connect to the API
 *	@param success A block object which will be executed when request finishes successfully.
 *	The block has a `TRSTrustbadge` object argument.
 *	@param failure A block object which will be executed when request finishes unsuccessfully.
 *	The block has an `NSError` object argument.
 *
 *	@return Initialized `NSURLSessionDataTask` object or `nil` if either `trustedShopsID` or `apiToken` is missing.
 */

- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID
												apiToken:(NSString *)apiToken
												 success:(void (^)(TRSTrustbadge *trustbadge))success
												 failure:(void (^)(NSError *error))failure;

- (NSMutableURLRequest *)localizedURLRequestForTrustcardWithColorString:(NSString *)hexString;

@end
