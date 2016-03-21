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

+ (NSURL *)trustMarkAPIURLForTSID:(NSString *)tsID andAPIEndPoint:(NSString *)apiEndPoint;

@end
