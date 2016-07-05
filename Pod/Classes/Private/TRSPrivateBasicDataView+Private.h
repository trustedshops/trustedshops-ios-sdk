//
//  TRSPrivateBasicDataView+Private.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

// This privately kept header defines private methods for the loading mechanism of our views.
// It should not be exposed to any public headers, only import it in .m files if you want to access the private
// methods of TRSPrivateBasicDataView in subclasses (as you should pverride them)
// The TRSPrivateBasicDataView class adopts this and subclasses should override these methods (as is explained
// in TRSPrivateBasicDataView.h).

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
// present the view's information.
// The default implementation in TRSPrivateBasicDataView should do nothing.
- (void)setupData:(id)data;

// This should be called right before loadViewDataFromBackendWithSuccessBlock:failureBlock: calls its success block,
// i.e. when the view is ready to be displayed. All relevant data properties (product grade etc.) are set.
// You should override this method to initialize all necessary subviews and add them to the view hierarchy.
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
