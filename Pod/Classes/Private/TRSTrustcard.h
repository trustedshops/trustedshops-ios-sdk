//
//  TRSTrustcard.h
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

#import <Foundation/Foundation.h>
@class TRSTrustbadge;

@interface TRSTrustcard : NSObject

- (void)showInLightboxForTrustbadge:(TRSTrustbadge *)trustbadge;

@end
