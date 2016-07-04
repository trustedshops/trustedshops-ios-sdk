//
//  TRSProductBaseView.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import <UIKit/UIKit.h>
#import "TRSPrivateBasicDataView.h"

@interface TRSProductBaseView : TRSPrivateBasicDataView

@property (nonatomic, copy) NSString *SKU;

- (instancetype)initWithFrame:(CGRect)frame
			   trustedShopsID:(NSString *)tsID
					 apiToken:(NSString *)apiToken
						  SKU:(NSString *)SKU NS_DESIGNATED_INITIALIZER;

@end
