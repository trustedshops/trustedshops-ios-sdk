//
//  NSURL+TRSURLExtensions.h
//  Pods
//
//  Created by Gero Herkenrath on 16.03.16.
//
//

FOUNDATION_EXPORT NSString * const TRSAPIEndPoint;
FOUNDATION_EXPORT NSString * const TRSAPIEndPointDebug;
FOUNDATION_EXPORT NSString * const TRSTrustcardTemplateURLString;
FOUNDATION_EXPORT NSString * const TRSTrustcardTemplateURLStringDebug;
FOUNDATION_EXPORT NSString * const TRSEndPoint; // this is used by the checkout process
FOUNDATION_EXPORT NSString * const TRSEndPointDebug; // dito
FOUNDATION_EXPORT NSString * const TRSPublicAPIEndPoint; // used to get a shop's grade, etc.
FOUNDATION_EXPORT NSString * const TRSPublicAPIEndPointDebug; // dito

#import <Foundation/Foundation.h>
@class TRSShop;

@interface NSURL (TRSURLExtensions)

+ (NSURL *)profileURLForShop:(TRSShop *)shop;

+ (NSURL *)profileURLForTSID:(NSString *)tsId countryCode:(NSString *)targetMarketISO3 language:(NSString *)languageISO2;

+ (NSURL *)trustMarkAPIURLForTSID:(NSString *)tsID debug:(BOOL)debug;

+ (NSURL *)shopGradeAPIURLForTSID:(NSString *)tsID debug:(BOOL)debug;

+ (NSURL *)productGradeAPIURLForTSID:(NSString *)tsID skuHash:(NSString *)skuHash debug:(BOOL)debug;

+ (NSURL *)localizedTrustcardURLWithColorString:(NSString *)hexString debug:(BOOL)debug;
@end
