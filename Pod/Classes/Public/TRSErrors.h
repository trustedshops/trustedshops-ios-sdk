#import <Foundation/Foundation.h>

/**
 The custom error domain used by the Trustbadge SDK.
 */

FOUNDATION_EXPORT NSString * const TRSErrorDomain;

/**	
 The type for error codes that are used in the Trustbadge SDK.
 */
typedef NS_ENUM(NSUInteger, TRSErrorCode) {
	/** An unknown error in the cintext of the Trustbadge SDK */
    TRSErrorDomainTrustbadgeUnknownError = 1000,
	/** The provided Trusted Shops shop ID was rejected as invalid by the API. */
    TRSErrorDomainTrustbadgeInvalidTSID,
	/** The provided Trusted Shops shop ID does not exist in the Trusted Shop database. */
    TRSErrorDomainTrustbadgeTSIDNotFound,
	/** The data returned for the trustbadge is corrupted or has an unknown format */
    TRSErrorDomainTrustbadgeInvalidData,
	/** The client token for the API is not valid. Currently this cannot happen, as no token is needed. */
	TRSErrorDomainTrustbadgeInvalidAPIToken,
	/** The TRSTrustbadgeView instance was set up without a Trusted Shops shop ID or without any client token (or both). */
	TRSErrorDomainTrustbadgeMissingTSIDOrAPIToken
};
