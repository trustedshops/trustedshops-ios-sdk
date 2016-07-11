//
//  TRSNetworkAgent+Commons.m
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import "TRSNetworkAgent+Commons.h"
#import "TRSErrors.h"

@implementation TRSNetworkAgent (Commons)

- (BOOL)didReturnErrorForTSID:(NSString *)tsID apiToken:(NSString *)apiToken failureBlock:(void (^)(NSError *error))failure {
	if (!tsID || !apiToken) {
		NSError *myError = [NSError errorWithDomain:TRSErrorDomain
											   code:TRSErrorDomainMissingTSIDOrAPIToken
										   userInfo:nil];
		if (failure)
			failure(myError);
		return YES;
	}
	return NO;
}

- (NSError *)standardErrorForResponseCode:(NSInteger)code {
	NSError *retVal = nil;
	switch (code) {
		case 400: {
			retVal = [NSError errorWithDomain:TRSErrorDomain
										 code:TRSErrorDomainInvalidTSID
									 userInfo:nil];
		} break;
			
		case 401: {
			retVal = [NSError errorWithDomain:TRSErrorDomain
										 code:TRSErrorDomainInvalidAPIToken
									 userInfo:nil];
		} break;
			
		case 404: {
			retVal = [NSError errorWithDomain:TRSErrorDomain
										 code:TRSErrorDomainTSIDNotFound
									 userInfo:nil];
		} break;
			
		default: {
			retVal = [NSError errorWithDomain:TRSErrorDomain
										 code:TRSErrorDomainUnknownError
									 userInfo:nil];
		} break;
	}
	return retVal;
}

@end
