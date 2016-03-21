#import "TRSNetworkAgent.h"

@implementation TRSNetworkAgent

+ (instancetype)sharedAgent {
    static TRSNetworkAgent *sharedAgent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAgent = [[self alloc] init];
    });

    return sharedAgent;
}

- (NSURLSessionDataTask *)GET:(NSURL *)url success:(void (^)(NSData *data))success failure:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))failure {
	
	return [self GET:url authToken:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)GET:(NSURL *)url
					authToken:(NSString *)token
					  success:(void (^)(NSData *data))success
					  failure:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))failure {
	
	NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	
	void (^completion)(NSData *data, NSURLResponse *response, NSError *error) = ^(NSData *data, NSURLResponse *response, NSError *error) {
		NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
		if (HTTPURLResponse.statusCode != 200) {
			if (failure) {
				failure(data, HTTPURLResponse, error);
			}
			return;
		}
		
		if (success) {
			success(data);
		}
	};
	
	NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	mutableRequest.allHTTPHeaderFields = @{@"Accept" : @"application/json"};
	if (token) {
		[mutableRequest addValue:token forHTTPHeaderField:@"client-token"];
	}
	NSURLSessionDataTask *task = [session dataTaskWithRequest:[mutableRequest copy] completionHandler:completion];
	[task resume];
	
	return task;
}

@end
