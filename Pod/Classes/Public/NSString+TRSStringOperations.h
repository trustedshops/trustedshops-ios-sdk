//
//  NSString+TRSStringOperations.h
//  Pods
//
//  Created by Gero Herkenrath on 22/07/16.
//
//

#import <Foundation/Foundation.h>

/**
 The mark string representing the 'excellent' mark description (best grade).
 */
FOUNDATION_EXPORT NSString *const kTRSTechnicalMarkExcellent;
/**
 The mark string representing the 'good' mark description.
 */
FOUNDATION_EXPORT NSString *const kTRSTechnicalMarkGood;
/**
 The mark string representing the 'fair' mark description (middle/average grade).
 */
FOUNDATION_EXPORT NSString *const kTRSTechnicalMarkFair;
/**
 The mark string representing the 'poor' mark description.
 */
FOUNDATION_EXPORT NSString *const kTRSTechnicalMarkPoor;
/**
 The mark string representing the 'very poor' mark description (worst grade).
 */
FOUNDATION_EXPORT NSString *const kTRSTechnicalMarkVeryPoor;
/**
 The mark string used for grades that haven't been calculated yet due to lack of reviews.
 */
FOUNDATION_EXPORT NSString *const kTRSTechnicalMarkNA;

/**
 The `TRSStringOperations` category adds (at the moment) a single method to `NSString` that allows
 converting the mark, or grade-, description string delivered by the API to be converted to a user readable, localized
 form that can be shown in the UI.
 The category's header also defines constants for the different mark/grade descriptions the API can deliver.
 */
@interface NSString (TRSStringOperations)

/**
 This method returns a localized, user readable representation of the string.
 
 If `self` is not equal to one of the strings defined in the constants defined in `NSString+TRSStringConversions.h`
 the method returns `nil`.
 Note that for `kTRSTechnicalMarkNA` it returns an empty string!
 
 @returns A localized, human readable representation of the string or `nil`.
 */
- (NSString *)readableMarkDescription;

@end
