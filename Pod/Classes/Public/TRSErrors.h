#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const TRSErrorDomain;

typedef NS_ENUM(NSUInteger, TRSErrorCode) {
    TRSErrorDomainTrustbadgeUnknownError = 1000,
    TRSErrorDomainTrustbadgeInvalidTSID,
    TRSErrorDomainTrustbadgeTSIDNotFound,
    TRSErrorDomainTrustbadgeInvalidData,
	TRSErrorDomainTrustbadgeInvalidAPIToken,
	TRSErrorDomainTrustbadgeMissingTSIDOrAPIToken
};
