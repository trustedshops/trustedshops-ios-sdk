//
//  TRSProduct.h
//  Pods
//
//  Created by Gero Herkenrath on 22/04/16.
//
//

#import <Foundation/Foundation.h>

/** 
 `TRSProduct` is a class representing any purchasable good in terms of relevance for Trusted Shops.
 Its required (`nonnull`) properties make up the minimum information Trusted Shops needs to 
 include it into our data base (so we can collect reviews for it).
 
 Use objects of this class in accordance with a `TRSOrder` to process any purchase from your shop with
 Trusted Shops (to offer your customer the Trusted Shops services, like buyer protection, etc.).
 
 You can also use this class to load information (like customer product reviews) from the Trusted Shops backend.
 */
@interface TRSProduct : NSObject

/**
 The URL associated with the product. 
 Usually this should link to your web shop or a place where the product is described and/or offered.
 */
@property (nonatomic, strong, nonnull)  NSURL *url;
/**
 A URL pointing to a picture of the product.
 This is typically used to display the product in various lists.
 */
@property (nonatomic, strong, nullable) NSURL *imageUrl;
/**
 The name of the product.
 */
@property (nonatomic, copy, nonnull)    NSString *name;
/**
 The stock keeping unit of the product.
 This is usually obtained from your stock keeping database.
 */
@property (nonatomic, copy, nonnull)    NSString *SKU;
/**
 The global trade item number of the product.
 */
@property (nonatomic, copy, nullable)   NSString *GTIN;
/**
 The manufacturer's part number of the product.
 */
@property (nonatomic, copy, nullable)   NSString *MPN;
/**
 The brand of the product.
 */
@property (nonatomic, copy, nullable)   NSString *brand;
/**
 An array containing customers' `TRSProductReview`s of this product.
 
 After initialization this property is `nil`. You need to call `loadReviewsFromBackendWithTrustedShopsID:apiToken:successBlock:failureBlock:`
 to load the review data from the Trusted Shops backend.
 */
@property (nonatomic, readonly, nullable) NSArray *reviews;
/**
 A flag to set this object into debug mode. In debug mode, data is not loaded from the Trusted Shops production API,
 but the QA environment instead. Note that the product and/or shop its from might not exist on the QA environment.
 
 This property is only relevant if you intend to use the object to load customers' product reviews from the
 Trusted Shops backend. Unless you call `loadReviewsFromBackendWithTrustedShopsID:apiToken:successBlock:failureBlock:` it has
 no influence on the product data or the object's behavior. By default it is NO.
 */
@property (nonatomic, assign) BOOL debugMode;

/**
 The `init` method is unavaiable on `TRSProduct`s.
 */
- (nullable instancetype)init __attribute__((unavailable("You cannot create an instance through init - please use initWithUrl:name:SKU: instead")));

/**
 The designated initializer.
 Set the optional properties afterwards.
 @param url A URL pointing to a picture of the product.
 @param name The name of the product..
 @param SKU The stock keeping unit of the product.
 */
- (nullable instancetype)initWithUrl:(nonnull NSURL *)url
								name:(nonnull NSString *)name
								 SKU:(nonnull NSString *)SKU NS_DESIGNATED_INITIALIZER;

/**
 Loads reviews for the product from the Trusted Shops database.
 
 You only need this method if you intend to show product reviews in your shop app. In this case it retrieves
 all customer reviews and calls its success block. Note that if no reviews are found, but the product is in the
 database, it still calls success. The error block is only called if an actual error occurs.
 After a successful call, the `reviews` property holds an array containing all reviews for the product (unless
 there are no reviews, in which case it is `nil`).
 You can then use this data in any way suitable for your app, for example in a table view or another custom view object.
 @param tsID the Trusted Shops shop ID the view uses to load its data from the backend.
 @param apiToken The client token the view uses to load its data from the backend. At the moment this is not needed and can be
 any `NSString`, but it must not be nil.
 @param success A block that is executed when the data was successfully loaded from the backend.
 @param failure A block that is executed when loading the data from the backend failed.
 */
- (void)loadReviewsFromBackendWithTrustedShopsID:(nullable NSString *)tsID
										apiToken:(nullable NSString *)apiToken
									successBlock:(nullable void (^)(void))success
									failureBlock:(nullable void (^)(NSError *_Nullable error))failure;
/**
 An NSString representing the product for the Trusted Shops API.
 You typically won't need this method yourself, it is used by the SDK internally for the most part.
 */
- (nonnull NSString *)jsStringDescription;
@end
