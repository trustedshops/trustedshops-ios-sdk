#import <Foundation/Foundation.h>

/**
 *  `TRSNetworkAgent` is used to handle network requests.
 */
@interface TRSNetworkAgent : NSObject

/**
 * @name Creating an Agent
 */

/**
 *  Creates and returns a singleton instance of `TRSNetworkAgent`.
 *
 *  @return A `TRSNetworkAgent` singleton
 */
+ (instancetype)sharedAgent;

/**
 * @name Making HTTP Requests
 */

/**
 *  Creates and runs an `NSURLSessionDataTask` with a `GET` request.
 *
 *  @param URLString The URL as a string.
 *  @param success   A block object which will be executed when request finishes successfully. The block has a data argument.
 *  @param failure   A block object which will be executed when request finishes unsuccessfully. The block a an error argument.
 */
- (void)GET:(NSString *)URLString success:(void (^)(NSData *data))success failure:(void (^)(NSError *error))failure;

@end
