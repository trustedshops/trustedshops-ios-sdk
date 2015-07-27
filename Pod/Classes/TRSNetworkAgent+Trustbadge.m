#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSErrors.h"

static NSString * const TRSNetworkAgentTrustbadgePath = @"/rest/public/v2/shops/%@/quality";


@implementation TRSNetworkAgent (Trustbadge)

- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID success:(void (^)(id trustbadge))success failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:TRSNetworkAgentTrustbadgePath, trustedShopsID];

    void (^successBlock)(NSData *data) = ^(NSData *data) {
        if (success) {
            success(data);
        }
    };

    void (^failureBlock)(NSData *data, NSHTTPURLResponse *response, NSError *error) = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            if (!error) {
                switch (response.statusCode) {
                    case 400: {
                        error = [NSError errorWithDomain:TRSErrorDomain
                                                    code:TRSErrorDomainTrustbadgeInvalidTSID
                                                userInfo:nil];
                    } break;

                    case 404: {
                        error = [NSError errorWithDomain:TRSErrorDomain
                                                    code:TRSErrorDomainTrustbadgeTSIDNotFound
                                                userInfo:nil];
                    } break;

                    default: {
                        error = [NSError errorWithDomain:TRSErrorDomain
                                                    code:TRSErrorDomainTrustbadgeUnknownError
                                                userInfo:nil];
                    } break;
                }
            }

            failure(error);
        }
    };

    return [self GET:path success:successBlock failure:failureBlock];
}

@end
