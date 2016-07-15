#import <Foundation/Foundation.h>

/**
 The custom error domain used by the Trustbadge SDK.
 */

FOUNDATION_EXPORT NSString * const TRSErrorDomain;

/**
 The type for error codes that are used in the Trustbadge SDK. The error domain of each error using these codes
 is defined as `TRSErrorDomain`.
 */
typedef NS_ENUM(NSUInteger, TRSErrorCode) {
	/** An unknown error occurred in the context of the Trustbadge SDK. */
	TRSErrorDomainUnknownError = 1000,
	/** An unknown error occurred in the context of the Trustbadge SDK.
	 @deprecated use `TRSErrorDomainUnknownError` instead. */
	TRSErrorDomainTrustbadgeUnknownError __deprecated_enum_msg("use TRSErrorDomainUnknownError instead") = TRSErrorDomainUnknownError,
	/** The provided Trusted Shops shop ID was rejected as invalid by the API. */
	TRSErrorDomainInvalidTSID,
	/** The provided Trusted Shops shop ID was rejected as invalid by the API.
	 @deprecated use `TRSErrorDomainInvalidTSID` instead. */
	TRSErrorDomainTrustbadgeInvalidTSID __deprecated_enum_msg("use TRSErrorDomainInvalidTSID instead") = TRSErrorDomainInvalidTSID,
	/** The provided Trusted Shops shop ID does not exist in the Trusted Shop database. */
	TRSErrorDomainTSIDNotFound,
	/** The provided Trusted Shops shop ID does not exist in the Trusted Shop database.
	 @deprecated use `TRSErrorDomainTSIDNotFound` instead. */
	TRSErrorDomainTrustbadgeTSIDNotFound __deprecated_enum_msg("use TRSErrorDomainTSIDNotFound instead") = TRSErrorDomainTSIDNotFound,
	/** The data returned from the API is corrupted or has an unknown format. */
	TRSErrorDomainInvalidData,
	/** The data returned from the API is corrupted or has an unknown format.
	 @deprecated use `TRSErrorDomainInvalidData` instead. */
	TRSErrorDomainTrustbadgeInvalidData __deprecated_enum_msg("use TRSErrorDomainInvalidData instead") = TRSErrorDomainInvalidData,
	/** The data returned from the API is valid, but contains different values than were expected/previously defined. */
	TRSErrorDomainUnexpectedData,
	/** The client token for the API is not valid. */
	TRSErrorDomainInvalidAPIToken,
	/** The client token for the API is not valid.
	 @deprecated use `TRSErrorDomainInvalidAPIToken` instead. */
	TRSErrorDomainTrustbadgeInvalidAPIToken __deprecated_enum_msg("use TRSErrorDomainInvalidAPIToken instead") = TRSErrorDomainInvalidAPIToken,
	/** A call to the API could not be made due to missing TSID or client token (or both were missing). No remote connection was made. */
	TRSErrorDomainMissingTSIDOrAPIToken,
	/** A call to the API could not be made due to missing TSID or client token (or both were missing). No remote connection was made.
	 @deprecated use `TRSErrorDomainMissingTSIDOrAPIToken` instead. */
	TRSErrorDomainTrustbadgeMissingTSIDOrAPIToken __deprecated_enum_msg("use TRSErrorDomainMissingTSIDOrAPIToken instead") = TRSErrorDomainMissingTSIDOrAPIToken,
	/** A product grade view was set up without an SKU. Bo remote connection was made. */
	TRSErrorDomainMissingSKU,
	/** The processOrder:onCompletion: method could not find a root view controller to present its popup */
	TRSErrorDomainProcessOrderNeedsRootViewController,
	/** The TRSCheckoutViewController did not finish processing the last call of processOrder:onCompletion: yet.
	 Only one order can be processed at a time. */
	TRSErrorDomainProcessOrderLastOrderNotFinished,
	/** The TRSOrder object passed to processOrder:onCompletion: is invalid or corrupted */
	TRSErrorDomainProcessOrderInvalidData
};
