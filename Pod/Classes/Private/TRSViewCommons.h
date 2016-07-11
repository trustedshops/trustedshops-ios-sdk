//
//  TRSViewCommons.h
//  Pods
//
//  Created by Gero Herkenrath on 14/06/16.
//
//

#import <UIKit/UIKit.h>

@interface TRSViewCommons : NSObject

+ (CGFloat)widthForLabel:(UILabel *)label withHeight:(CGFloat)height;
+ (CGFloat)optimalHeightForFontInLabel:(UILabel *)label;
+ (CGFloat)widthForLabel:(UILabel *)label withHeight:(CGFloat)height optimalFontSize:(CGFloat *)optSize;

+ (CGFloat)widthForLabel:(UILabel *)label
			  withHeight:(CGFloat)height
		 optimalFontSize:(CGFloat *)optSize
  smallerCharactersScale:(CGFloat)scale;

+ (NSAttributedString *)attributedGradeStringFromString:(NSString *)unformatted
									  withBasePointSize:(CGFloat)pointSize
											scaleFactor:(CGFloat)scale
											 firstColor:(UIColor *)firstColor
											secondColor:(UIColor *)secondColor
												   font:(UIFont *)font;

+ (NSAttributedString *)attributedGradeStringFromString:(NSString *)unformatted
									  withBasePointSize:(CGFloat)pointSize
											scaleFactor:(CGFloat)scale;

+ (NSString *)gradeStringForNumber:(NSNumber *)number;

+ (NSString *)reviewCountStringForNumber:(NSNumber *)number;

@end
