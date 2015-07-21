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

- (instancetype)init {
    self = [super init];

    if (!self) {
        return nil;
    }

    return self;
}

- (void)GET:(NSString *)URLString success:(void (^)(NSData *data))success failure:(void (^)(NSError *error))failure {
    NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];

    void (^completion)(NSData *data, NSURLResponse *response, NSError *error) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
        if (HTTPURLResponse.statusCode != 200) {
            if (failure) {
                failure(error);
            }
            return;
        }

        if (success) {
            success(data);
        }
    };

    [[session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:completion] resume];
}

@end
