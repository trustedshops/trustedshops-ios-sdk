//
//  TRSShop.h
//  Pods
//
//  Created by Gero Herkenrath on 08.03.16.
//
//

#import <Foundation/Foundation.h>
#import "TRSTrustMark.h"

@interface TRSShop : NSObject

@property (nonatomic, strong) NSString		*tsId;
@property (nonatomic, strong) NSString		*url;
@property (nonatomic, strong) NSString		*name;
@property (nonatomic, strong) NSString		*languageISO2;		// defaults to @"en" on init
@property (nonatomic, strong) NSString		*targetMarketISO3;	// defaults to @"EUO" on init
@property (nonatomic, strong) TRSTrustMark	*trustMark;

- (instancetype)initWithDictionary:(NSDictionary *)shopInfo NS_DESIGNATED_INITIALIZER;

- (NSURL *)shopProfileURL;

@end
