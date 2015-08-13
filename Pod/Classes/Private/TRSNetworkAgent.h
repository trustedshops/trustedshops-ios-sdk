#import <Foundation/Foundation.h>

/**
 *  `TRSNetworkAgent` is used to handle network requests.
 */
@interface TRSNetworkAgent : NSObject

/**
 *  The base URL for the agent.
 */
@property (nonatomic, readonly, copy) NSURL *baseURL;

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
 *  Initializes an `TRSNetworkAgent` with the specified base URL.
 *
 *  @param url The base URL for the agent
 *
 *  @return An initialized agent
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL;

/**
 * @name Making HTTP Requests
 */

/**
 *  Creates and runs an `NSURLSesseionDataTaks` with a `GET` request and returns the task.
 *
 *  @param path    The path of the URL
 *  @param success A block object which will be executed when request finishes successfully. The block has a data argument.
 *  @param failure A block object which will be executed when request finishes successfully. The block has a data argument.
 *
 *  @return Initialized `NSURLSessionDataTaks` object
 */
- (NSURLSessionDataTask *)GET:(NSString *)path success:(void (^)(NSData *data))success failure:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))failure;

@end
