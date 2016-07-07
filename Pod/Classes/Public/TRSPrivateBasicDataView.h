//
//  TRSPrivateBasicDataView.h
//  Pods
//
//  Created by Gero Herkenrath on 04/07/16.
//
//

#import <UIKit/UIKit.h>

/**
 `TRSPrivateBasicDataView` is an abstract subclass of `UIView` for the purpose of defining common behavior and 
 properties of all views that load data from the Trusted Shops API backend.
 
 Nevertheless, it is a public class of the library to allow you to identify common properties see how the loading
 mechanism works. You can actually instantiate it, but it will not do anything useful (alone it is basically just a 
 `UIView`). However, you *must not* call `loadViewDataFromBackendWithSuccessBlock:failureBlock:` on any such instances 
 directly. This will throw a `TRSPrivateBasicDataViewSubclassingException`.
 
 ### Subclassing notes
 
 You should not directly subclass `TRSPrivateBasicDataView` yourself, rely on one of its existing subclasses instead.
 The mechanic in which it should be subclassed is private at the moment and subject to change. Generally speaking,
 subclasses provide a way to load data from the Trusted Shops backend in a specific way that `TRSPrivateBasicDataView`
 expects, so they all are able to follow the same "instantiate -> load -> display TS data" pattern.
 
 @warning Do not subclass this class youself. Do not call `loadViewDataFromBackendWithSuccessBlock:failureBlock:` 
 on an instance of `TRSPrivateBasicDataView`.
 */
@interface TRSPrivateBasicDataView : UIView

/**
 The Trusted Shops shop ID the view uses to load its data from the backend.
 */
@property (nonatomic, copy) NSString *tsID;
/**
 The client token the view uses to load its data from the backend. At the moment this is not needed and can be
 any `NSString`, but it must not be nil.
 */
@property (nonatomic, copy) NSString *apiToken;
/**
 A flag to set this view into debug mode. In debug mode, data is not loaded from the Trusted Shops production API,
 but the QA environment instead. Note that the shop defined by `tsID` might not exist on the QA environment.
 */
@property (nonatomic, assign) BOOL debugMode;

/**
 Loads the view's data from the Trusted Shops backend.
 
 You should only ever call this method on subclasses of `TRSPrivateBasicDataView`. They will override the necessary
 private methods that ensure data can be loaded. Calling it on an instance of `TRSPrivateBasicDataView` itself will
 ultimately result in an exception.
 
 Note that this does not mean the method itself throws the exception. That happens during the private mechanism
 responsible for the loading of a concrete kind of data from the Trusted Shops backend. Because of this, you
 should also not override the method yourself, in fact, subclassing `TRSPrivateBasicDataView` is not recommended at all.
 
 @param success A block that is executed when the data was successfully loaded from the backend.
 @param failure A block that is executed when loading the data from the backend failed. 
 It has an `error` as argument specifying the cause of the fail.
 */
- (void)loadViewDataFromBackendWithSuccessBlock:(void (^)(void))success failureBlock:(void (^)(NSError *error))failure;

// this is just a more convenient way to init the base properties needed to load from the backend.
/**
 The designated initializer of all views loading data from the Trusted Shops backend.
 
 Subclasses might override this to provide more specific data needed for their own call to their corresponding component
 of the Trusted Shops backend. The parameters given here are the bare minimum that is needed for all calls to the
 backend, so subclasses call it in their own designated initializers.
 
 @param frame The frame for the view.
 @param tsID the Trusted Shops shop ID the view uses to load its data from the backend.
 @param apiToken The client token the view uses to load its data from the backend. At the moment this is not needed and can be
 any `NSString`, but it must not be nil.
 */
- (instancetype)initWithFrame:(CGRect)frame trustedShopsID:(NSString *)tsID apiToken:(NSString *)apiToken NS_DESIGNATED_INITIALIZER;

@end
