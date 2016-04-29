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
 An NSString representing the product for the Trusted Shops API.
 You typically won't need this method yourself, it is used by the SDK internally for the most part.
 */
- (nonnull NSString *)jsStringDescription;
@end
