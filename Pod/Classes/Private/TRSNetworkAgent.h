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
 *	Creates and runs an @c NSURLSesseionDataTaks with a @c GET request and returns the task.
 *
 *	@param url The url to GET from
 *	@param token A client-token needed to authenticate (currently checked by the API)
 *	@param success A block object which will be executed when request finishes successfully. The block has a data argument.
 *	@param failure A block object which will be executed when request finishes successfully. 
 *	The block has a data, a response, and an error argument.
 *
 *	@return Initialized `NSURLSessionDataTaks` object or `nil` if the `authToken` is missing (i.e. also  `nil`).
 */
- (NSURLSessionDataTask *)GET:(NSURL *)url
					authToken:(NSString *)token
					  success:(void (^)(NSData *data))success
					  failure:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))failure;

/**
 *	A debug flag. Determines whether to load from the debug (QA) API or the production API.
 *	Defaults to NO.
 */
@property (nonatomic, assign) BOOL debugMode;

@end
