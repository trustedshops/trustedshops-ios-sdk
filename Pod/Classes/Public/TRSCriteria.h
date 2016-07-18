//
//  TRSCriteria.h
//  Pods
//
//  Created by Gero Herkenrath on 15/07/16.
//
//

#import <Foundation/Foundation.h>

/**
 The type used used to distinguish different kinds of TRSCriteria.
 */
typedef NS_ENUM(NSUInteger, TRSCriteriaType) {
	/** The type of criteria is not known. This typically means the SDK doesn't understand the type yet or denotes an error. */
	kTRSUnknownCriteriaType,
	/** The TOTAL type of criteria. This is a general criteria, meaning the product was generally reviewed. */
	kTRSTotal
};

/**
 The `TRSCriteria` class represents one component of `TRSProductReview` objects.
 
 The way product reviews at Trusted Shops are saved allows to specify various subcategories providing further
 information about what exactly wa reviewed about the product. At the moment there is only one type of criteria,
 "TOTAL", meaning a product was reviewed as a whole, not specifying individual aspects separately.
 
 You do not need to instantiate objects of this class yourself, they are constructed for you as part of the
 reviews array that is generated when you call `[TRSProduct loadReviewsFromBackendWithTrustedShopsID:apiToken:successBlock:failureBlock:]`.
 */
@interface TRSCriteria : NSObject

/** The mark, or grade this category was given by the reviewer. Ranges between 1 and 5. */
@property (nonatomic, readonly, nonnull) NSNumber *mark;
/** The type of criteria, or "subreview". At the moment this is always `kTRSTotal`. */
@property (nonatomic, readonly) TRSCriteriaType type;

/**
 The designated initializer.
 
 @param mark The The mark, or grade this category was given by the reviewer. Values above 5 are treated as 5, values below 1 are treated as 1
 @param type The type of criteria, or "subreview"
 */
- (nullable instancetype)initWithMark:(nonnull NSNumber *)mark type:(TRSCriteriaType)type NS_DESIGNATED_INITIALIZER;

/**
 Trsnalates an `NSString` retrieved from the Trusted Shops backend to an according `TRSCriteriaType` value
 
 This method is internally used during construction of the `TRSProductReview` array.

 @param typeString An `NSString` as it is given by the Trusted Shops backend.
 */
+ (TRSCriteriaType)criteriaTypeFromString:(nonnull NSString *)typeString;

@end
