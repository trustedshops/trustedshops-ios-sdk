#import "TRSNetworkAgent.h"

static NSString * const TRSNetworkAgentBaseURL = @"https://api-qa.trustedshops.com/";

@interface TRSNetworkAgent ()

@property (nonatomic, readwrite) NSURL *baseURL;

@end


@implementation TRSNetworkAgent

+ (instancetype)sharedAgent {
    static TRSNetworkAgent *sharedAgent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAgent = [[self alloc] initWithBaseURL:[NSURL URLWithString:TRSNetworkAgentBaseURL]];
    });

    return sharedAgent;
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];

    if (!self) {
        return nil;
    }

    _baseURL = baseURL;

    return self;
}

- (NSURLSessionDataTask *)GET:(NSString *)path success:(void (^)(NSData *data))success failure:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))failure {
	
	return [self GET:path authToken:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)GET:(NSString *)path
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
	
	NSURL *requestURL = [NSURL URLWithString:path relativeToURL:self.baseURL];
	NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:requestURL];
	mutableRequest.allHTTPHeaderFields = @{@"Accept" : @"application/json"};
	if (token) {
		[mutableRequest addValue:token forHTTPHeaderField:@"client-token"];
	}
	NSURLSessionDataTask *task = [session dataTaskWithRequest:[mutableRequest copy] completionHandler:completion];
	[task resume];
	
	return task;
}

@end
