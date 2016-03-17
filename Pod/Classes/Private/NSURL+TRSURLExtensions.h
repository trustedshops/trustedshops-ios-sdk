//
//  NSURL+TRSURLExtensions.h
//  Pods
//
//  Created by Gero Herkenrath on 16.03.16.
//
//

#import <Foundation/Foundation.h>
@class TRSShop;

@interface NSURL (TRSURLExtensions)

+ (NSURL *)profileURLForShop:(TRSShop *)shop;

// This method is currently not used as the API URL is managed by TRSNetworkAgent and TRSNetworkAgent+Trustbadge
// TODO: change those two and use this here to mimic Android SDK
+ (NSURL *)trustMarkAPIURLForTSID:(NSString *)tsID andAPIEndPoint:(NSString *)apiEndPoint;

@end
