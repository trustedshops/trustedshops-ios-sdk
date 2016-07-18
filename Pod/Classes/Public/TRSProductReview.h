//
//  TRSProductReview.h
//  Pods
//
//  Created by Gero Herkenrath on 15/07/16.
//
//

#import <Foundation/Foundation.h>

/**
 A `TRSProductReview` represents one specific customer's review about a given product.
 
 You shouldn't create instances of this class yourself, instead use 
 `[TRSProduct loadReviewsFromBackendWithTrustedShopsID:apiToken:successBlock:failureBlock:]` to load all reviews
 for a specific product from the Trusted Shops backend. 
 
 You can then use `TRSProductReview` objects to, for example, display reviews in a table to show your users
 what other customers think of the product.
 */
@interface TRSProductReview : NSObject

/** The date on which this review was given. */
@property (nonatomic, readonly, nonnull) NSDate *creationDate;
/** The comment the customer who reviewed the product gave. */
@property (nonatomic, readonly, nonnull) NSString *comment;
/** The mark, or grade, the customer gave the product. Lies between 1 and 5, where 1 is the worst rating and 5 the best. */
@property (nonatomic, readonly, nonnull) NSNumber *mark;
/** A unique identifier for this review. */
@property (nonatomic, readonly, nonnull) NSString *UID;
/** An array of `TRSCriteria` objects, "subcategories" associated with this review. */
@property (nonatomic, readonly, nonnull) NSArray *criteria;

/**
 The designated initializer.
 
 This method is mainly used internally during the construction of reviews in
 `[TRSProduct loadReviewsFromBackendWithTrustedShopsID:apiToken:successBlock:failureBlock:]`.
 @param creationDate the creation date of the review.
 @param comment the comment the reviewer gave.
 @param mark the mark, or grade, the reviewer gave.
 @param UID the UID used in the Trusted Shops backend.
 @param criteria an array of `TRSCriteria` objects.
 */
- (nullable instancetype)initWithCreationDate:(nonnull NSDate *)creationDate
									  comment:(nonnull NSString *)comment
										 mark:(nonnull NSNumber *)mark
										  UID:(nonnull NSString *)UID
									 criteria:(nonnull NSArray *)criteria NS_DESIGNATED_INITIALIZER;
/**
 The `init` method is unavaiable on `TRSProductReview`s.
 */
- (nullable instancetype)init __attribute__((unavailable("You cannot create an instance through init - please use initWithCreationDate:comment:mark:UID:criteria:")));

@end
