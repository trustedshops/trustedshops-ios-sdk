//
//  TRSTrustcard.h
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

#import <Foundation/Foundation.h>
@class TRSTrustbadge;

@interface TRSTrustcard : UIViewController

// set this to the remote folder with the trustcard info. If it's nil, we use a local fallback
@property (nonatomic, copy) NSString *remoteCertLocationFolder;

- (void)showInLightboxForTrustbadge:(TRSTrustbadge *)trustbadge;

@end
