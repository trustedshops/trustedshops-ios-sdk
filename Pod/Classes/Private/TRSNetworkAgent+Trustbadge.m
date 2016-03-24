#import "TRSNetworkAgent+Trustbadge.h"
#import "TRSTrustbadge.h"
#import "NSURL+TRSURLExtensions.h"
#import <Trustbadge/Trustbadge.h>

NSString * const TRSAPIEndPoint = @"cdn1.api.trustedshops.com";


@implementation TRSNetworkAgent (Trustbadge)

- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID success:(void (^)(TRSTrustbadge *trustbadge))success failure:(void (^)(NSError *error))failure {
	
	return [self getTrustbadgeForTrustedShopsID:trustedShopsID apiToken:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)getTrustbadgeForTrustedShopsID:(NSString *)trustedShopsID
												apiToken:(NSString *)apiToken
												 success:(void (^)(TRSTrustbadge *trustbadge))success
												 failure:(void (^)(NSError *error))failure {
	
	if (!trustedShopsID || !apiToken) {
		NSError *myError = [NSError errorWithDomain:TRSErrorDomain
											   code:TRSErrorDomainTrustbadgeMissingTSIDOrAPIToken
										   userInfo:nil];
		if (failure)
			failure(myError);
		return nil;
	}
	
	void (^successBlock)(NSData *data) = ^(NSData *data) {
		TRSTrustbadge *trustbadge = [[TRSTrustbadge alloc] initWithData:data];
		
		if (!trustbadge) {
			if (!failure) {
				return;
			}
			NSError *error = [NSError errorWithDomain:TRSErrorDomain
												 code:TRSErrorDomainTrustbadgeInvalidData
											 userInfo:nil];
			failure(error);
			return;
		}
		
		if (!success) {
			return;
		}
		
		success(trustbadge);
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
						
					case 401: {
						error = [NSError errorWithDomain:TRSErrorDomain
													code:TRSErrorDomainTrustbadgeInvalidAPIToken
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
	
	return [self GET:[NSURL trustMarkAPIURLForTSID:trustedShopsID andAPIEndPoint:TRSAPIEndPoint]
		   authToken:apiToken
			 success:successBlock
			 failure:failureBlock];

}

@end
