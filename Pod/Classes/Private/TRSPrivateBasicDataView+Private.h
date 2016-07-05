//
//  TRSPrivateBasicDataView+Private.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

/*
 This is a private header to keep the public interface clean from these internal helper methods.
 It is part of the abstract TRSPrivateBasicDataView class, however, and all classes inheriting from that
 should import this header along with the public one in their .m file.
 
 How the class is supposed to be used:
 This serves as a base class for any views accessing the Trsuted Shops backend. It can't work on its own, since
 there is no general view data in the backend. Different views should use different categories of TRSNetworkAgent
 to obtain their relevant data, but the general loading mechanism and template methods for layout and data
 preparation are provided by this class.
 
 Various methods to override are not defined in this header (to keep them invisible from any public views),
 but in the TRSPrivateBasicDataViewLoading protocol. These methods are to be overridden by subclasses (except 5), which
 you can override, but don't have to). In summry those are:
 
 1: (void)finishInit;
 2: (BOOL)setupData:(id)data;
 3: (void)finishLoading;
 4: (void)performNetworkRequestWithSuccessBlock:(void (^)(id result))successBlock failureBlock:(void(^)(NSError *error))failureBlock;
 5: (NSString *)logStringForErrorCode:
 
 1) should be used to set up any basic proprties of the view. It is called during the designated initializers (so you should
 NOT call it yourself in the subclass).
 
 2) is called in the successBlock parameter that is given to performNetworkRequestWithSuccessBlock:failureBlock: (see 4)).
 Here you can save any data in properties in your view. The passed object is the same that the TRSNetworkAgent category
 method you set up returns, e.g. an NSDictionary for getProductGradeForTrustedShopsID:apiToken:SKU:success:failure:
 If for some reason the data turns out to be unusable, return NO. The superclass will then invoke the failure block
 argument that was passed to it in loadViewDataFromBackendWithSuccessBlock:failureBlock: with an appropriate error.
 
 3) is called right before the success block given to loadViewDataFromBackendWithSuccessBlock:failureBlock: is called.
 Here you should build the view hierarchy with the data that was just obtained from the backend (and stored
 somewhere by 2)). Note that the success block is called in any case after this method returns control flow
 to the superclass
 
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

@interface TRSPrivateBasicDataView ()

// This is only needed to satisfy the compiler (for NS_DESIGNATED_INITIALIZER)
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

// NOTE: This is to be overriden in all subclasses of TRSPrivateBasicDataView.
// The method is called in all designated initializers, i.e. initWithFrame:trustedShopsID:apiToken and initWithCoder:.
// When you override initWithCoder: to de-serialize custom properties, be aware that, because of this, finishInit is
// called BEFORE you unarchive these properties (since the call to super is the first thing you should do when
// overriding said method).
// There should be no need to override initWithFrame:trustedShopsID:apiToken, you can do all according things in finishInit instead.
// The default implementation in TRSPrivateBasicDataView should do nothing.
- (void)finishInit;

// This should be called right at the start of the success block of performRemoteGetWithSuccess:ailure:
// Subclasses can use this to process the response object and setup their internal data properties needed to
// present the view's information. If the data can't be setup correctly, don't store any of it and return NO
// otherwise return YES.
// The default implementation in TRSPrivateBasicDataView should do nothing.
- (BOOL)setupData:(id)data;

// This should be called right before loadViewDataFromBackendWithSuccessBlock:failureBlock: calls its success block,
// i.e. when the view is ready to be displayed. All relevant data properties (product grade etc.) are set.
// You should override this method to initialize all necessary subviews and add them to the view hierarchy.
// Note that afterwards, the success block is called in any case.
// The default implementation in TRSPrivateBasicDataView should do nothing.
- (void)finishLoading;

// Must be overridden in subclasses!
// This method should use the appropriate TRSNetworkAgent category to obtain the data relevant for the view
// from the backend. On success it MUST invoke the success block (with the result) and on failure it MUST do so with
// the failure block (simply passing the error).
// The default implementation in TRSPrivateBasicDataView throws an error!
- (void)performNetworkRequestWithSuccessBlock:(void (^)(id result))successBlock failureBlock:(void(^)(NSError *error))failureBlock;

// This method _can_ be overridden, but if you do so, you should call super first. It returns a string that
// will be logged to the console for a given error code or nil, if it doesn't know the error code.
// By default, TRSPrivateBasicDataView understands TRSErrorDomainInvalidAPIToken, TRSErrorDomainInvalidTSID,
// TRSErrorDomainTSIDNotFound, TRSErrorDomainInvalidData, and TRSErrorDomainMissingTSIDOrAPIToken. For any other
// error, this method returns nil in this default implementation. If, however, the domain is TRSErrorDomain AND
// the error not one of the above, the view will log "[trustbadge] An unkown error occured." to the console, so
// you should override it to add any additional error code log messages relevant to your view (e.g. missing SKU).
- (NSString *)logStringForErrorCode:(NSInteger)code;

@end
