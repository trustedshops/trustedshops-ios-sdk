#import "TRSNetworkAgent.h"


@class TRSTrustbadge;

/**
 *	@c TRSNetworkAgent+Trustbadge is a category of @c TRSNetworkAgent to handle network requests for Trustbadge.
 */
@interface TRSNetworkAgent (Trustbadge)

/**
 *  @name Making Trustbadge Requests
 */

// Method is deprecated
//- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID success:(void (^)(TRSTrustbadge *trustbadge))success failure:(void (^)(NSError *error))failure;

/**
 *	Creates and runs a request to fetch Trustbadge
 *	@discussion	Test
 *
 *	@param trustedShopsID	Trusted Shops ID for the shop
 *	@param apiToken			The token required to connect to the API
 *	@param success			A block object which will be executed when request finishes successfully. 
 *								The block has a @c TRSTrustbadge object argument.
 *	@param failure			A block object which will be executed when request finishes unsuccessfully. 
 *								The block has an @c NSError object argument.
 *
 *	@return Initialized @c NSURLSessionDataTask object or @c nil if either @c trustedShopsID or @c apiToken is missing.
 */

- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID
												apiToken:(NSString *)apiToken
												 success:(void (^)(TRSTrustbadge *trustbadge))success
												 failure:(void (^)(NSError *error))failure;

@end
