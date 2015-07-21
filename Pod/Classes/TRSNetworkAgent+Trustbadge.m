#import "TRSNetworkAgent+Trustbadge.h"

static NSString * const TRSNetworkAgentTrustbadgePath = @"/public/v2/shops/%@/quality";


@implementation TRSNetworkAgent (Trustbadge)

- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID success:(void (^)(id trustbadge))success failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:TRSNetworkAgentTrustbadgePath, trustedShopsID];

    void (^successBlock)(NSData *data) = ^(NSData *data) {
        if (success) {
            success(data);
        }
    };

    void (^failureBlock)(NSError *error) = ^(NSError *error) {
        if (failure) {
            failure(error);
        }
    };

    return [self GET:path success:successBlock failure:failureBlock];
}

@end
