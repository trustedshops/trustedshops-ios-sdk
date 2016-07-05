//
//  TRSPrivateBasicDataView.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

/*
 This is an abstract class that you shoud NOT instantiate.
 It serves as a general template for any views that need to load their data from the Trusted Shops backend.
 */

#import <UIKit/UIKit.h>

@interface TRSPrivateBasicDataView : UIView

@property (nonatomic, copy) NSString *tsID;
@property (nonatomic, copy) NSString *apiToken;
@property (nonatomic, assign) BOOL debugMode;

// The method to load data from the backend. Since its structure is a template for different API points, subclasses
// should NOT override this method, but instead the methods from the private protocol TRSPrivateBasicDataViewLoading
- (void)loadViewDataFromBackendWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure;

// this is just a more convenient way to init the base properties needed to load from the backend.
- (instancetype)initWithFrame:(CGRect)frame trustedShopsID:(NSString *)tsID apiToken:(NSString *)apiToken NS_DESIGNATED_INITIALIZER;

@end
