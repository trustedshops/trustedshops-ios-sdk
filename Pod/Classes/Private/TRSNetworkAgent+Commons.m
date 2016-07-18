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

- (BOOL)didReturnErrorForTSID:(NSString *)tsID
					 apiToken:(NSString *)apiToken
						  SKU:(NSString *)SKU
				 failureBlock:(void (^)(NSError *error))failure {
	BOOL retVal = [self didReturnErrorForTSID:tsID apiToken:apiToken failureBlock:failure];
	if (!retVal) {
		NSString *skuHash = [self hashForSKU:SKU];
		if (!skuHash) {
			NSError *myError = [NSError errorWithDomain:TRSErrorDomain
												   code:TRSErrorDomainMissingSKU
											   userInfo:nil];
			if (failure)
				failure(myError);
			retVal = YES;
		}
	}
	return retVal;
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

- (NSString *)hashForSKU:(NSString *)SKU{
	if (!SKU) {
		return nil;
	}
	const char *inUTF8 = [SKU UTF8String];
	NSMutableString *asHex = [NSMutableString string];
	while (*inUTF8) {
		[asHex appendFormat:@"%02X", *inUTF8++ & 0x00FF];
	}
	return [NSString stringWithString:asHex];
}

@end
