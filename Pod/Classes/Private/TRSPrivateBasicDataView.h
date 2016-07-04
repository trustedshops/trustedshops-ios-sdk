//
//  TRSPrivateBasicDataView.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

/*
 How this class is supposed to be used:
 This serves s a base class for any views accessing the Trsuted Shops backend. It can't work on its own, since
 there is no general view data in the backend. Different views should use different categories of TRSNetworkAgent
 to obtain their relevant data, but the general loading mechanism and template methods for layout and data 
 preparation are provided by this class. 
 
 Various methods to override are not defined in this header (to keep them invisible from any public views),
 but in the TRSPrivateBasicDataViewLoading protocol. These methods are to be overridden by subclasses (except 5), which
 you can override, but don't have to). In summry those are:
 
 1: (void)finishInit;
 2: (void)setupData:(id)data;
 3: (void)finishLoading;
 4: (void)performNetworkRequestWithSuccessBlock:(void (^)(id result))successBlock failureBlock:(void(^)(NSError *error))failureBlock;
 5: (NSString *)logStringForErrorCode:
 
 1) should be used to set up any basic proprties of the view. It is called during the designated initializers (so you should 
 NOT call it yourself in the subclass).
 
 2) is called in the successBlock parameter that is given to performNetworkRequestWithSuccessBlock:failureBlock: (see 4)).
 Here you can save any data in properties in your view. The passed object is the same that the TRSNetworkAgent category
 method you set up returns, e.g. an NSDictionary for getProductGradeForTrustedShopsID:apiToken:SKU:success:failure:
 
 3) is called right before the success block given to loadViewDataFromBackendWithSuccessBlock:failureBlock: is called.
 Here you should build the view hierarchy with the data that was just obtained from the backend (and stored
 somewhere by 2))
 
 4) is not to be confused with loadViewDataFromBackendWithSuccessBlock:failureBlock: !
 Here you should invoke whatever category method of TRSNetworkAgent is respinsbile for fetching the data your view subclass
 needs! On success respectively error you MUST invoke the corresponding block that is passed to this method! (Most likely
 you can just pass the blocks to your category method, if that has corresponding parameters.
 
 5) doesn't need to be overridden, but you probably should do that if you must handle errors besides the common
 ones (like TSID not found and such). If you do that, call super first, and if that returns nil, try
 to create a log message suitable for your error. If you don't know the error either, return nil for a standard
 "unknown error" to be logged. (note that this is just useful for logging, the actual error handlers still
 propagate the error to the relevant failure blocks).
 
 With these methods overridden, any subclass view will work like the following:
 Regardless how it is initialized, finishInit takes care of how it looks right after initialization and before
 data is loaded (note that also initWithCoder calls this before all properties are decoded).
 After init, the view can be loaded with loadViewDataFromBackendWithSuccessBlock:failureBlock:. The method prepares
 the TRSNetworkAgent as far as it can and then relies on your implementation of performNetworkRequestWithSuccessBlock:failureBlock:
 to actually make the agent get data. You don't need to worry about handling common errors or callbacks.
 On success, it calls first setupData: and then finishLoading, so your implementation of these defines how the view
 is built up internally. From then on it acts exactly like any UIView, i.e. you need to override e.g. layoutSubviews
 accordingly to adapt to UI changes etc.
 
 Due to this design, you MUST NOT override loadViewDataFromBackendWithSuccessBlock:failureBlock: and you MUST
 override performNetworkRequestWithSuccessBlock:failureBlock: as is explained under 4)
 
 Furthermore, you should not expose the methods from the private protocol to public views.

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
