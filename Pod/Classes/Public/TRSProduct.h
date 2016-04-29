//
//  TRSProduct.h
//  Pods
//
//  Created by Gero Herkenrath on 22/04/16.
//
//

#import <Foundation/Foundation.h>

@interface TRSProduct : NSObject

@property (nonatomic, strong, nonnull)  NSURL *url;
@property (nonatomic, strong, nullable) NSURL *imageUrl;
@property (nonatomic, copy, nonnull)    NSString *name;
@property (nonatomic, copy, nonnull)    NSString *SKU;
@property (nonatomic, copy, nullable)   NSString *GTIN;
@property (nonatomic, copy, nullable)   NSString *MPN;
@property (nonatomic, copy, nullable)   NSString *brand;

- (nullable instancetype)init __attribute__((unavailable("You cannot create an instance through init - please use initWithUrl:name:SKU: instead")));

- (nullable instancetype)initWithUrl:(nonnull NSURL *)url
								name:(nonnull NSString *)name
								 SKU:(nonnull NSString *)SKU NS_DESIGNATED_INITIALIZER;

- (nonnull NSString *)jsStringDescription;
@end
