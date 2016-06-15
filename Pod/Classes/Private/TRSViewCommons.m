//
//  TRSViewCommons.m
//  Pods
//
//  Created by Gero Herkenrath on 14/06/16.
//

#import "TRSViewCommons.h"

@implementation TRSViewCommons

+ (CGFloat)widthForLabel:(UILabel *)label withHeight:(CGFloat)height {
	return [TRSViewCommons widthForLabel:label withHeight:height optimalFontSize:NULL];
}

+ (CGFloat)optimalHeightForFontInLabel:(UILabel *)label {
	CGFloat retVal = 13.0;
	[TRSViewCommons widthForLabel:label withHeight:label.frame.size.height optimalFontSize:&retVal];
	return retVal;
}

+ (CGFloat)widthForLabel:(UILabel *)label
			  withHeight:(CGFloat)height
		 optimalFontSize:(CGFloat *)optSize {
	return [TRSViewCommons widthForLabel:label withHeight:height optimalFontSize:optSize smallerCharactersScale:1.0];
}

// this could probably be refactored a lot, but it works for now.
// The idea is that it takes a height and a label and let's you know how wide the label needs to be to
// hold the text while simultaneously using a fontsize that's as large as possible and fits in the provided height.
// It does so kinda brute-force-ish, simply trying out sizes, o I defined max and min, too.
+ (CGFloat)widthForLabel:(UILabel *)label
			  withHeight:(CGFloat)height
		 optimalFontSize:(CGFloat *)optSize
  smallerCharactersScale:(CGFloat)scale {
	
	if (scale == 0.0 || scale > 1.0) {
		scale = 1.0;
	}
	
	if (!label || height == 0) {
		if (optSize != NULL) {
			*optSize = 0.0;
		}
		return 0.0;
	}
	CGFloat tempMin = 11.0;
	CGFloat tempMax = 42.0;
	CGFloat mid = 0.0;
	CGFloat difference = 0.0;
	NSString *testString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	while (tempMin <= tempMax) {
		mid = tempMin + floor((tempMax - tempMin) / 2);
		UIFont *tempFont = [UIFont fontWithName:label.font.fontName size:mid];
		NSDictionary *atts = @{NSFontAttributeName : tempFont};
		difference = height - [testString sizeWithAttributes:atts].height;
		
		if (mid == tempMin || mid == tempMax) {
			if (difference < 0) {
				if (optSize != NULL) {
					*optSize = mid - 2.0; // - 1.0 for general size fitting and - 1.0 in this special case
				}
				return [[TRSViewCommons attributedGradeStringFromString:label.text
														 withBasePointSize:mid - 2.0
															   scaleFactor:scale] size].width;
			}
			if (optSize != NULL) {
				*optSize = mid - 1.0; // see above, apparently also an issue for UILabel.
			}
			return [[TRSViewCommons attributedGradeStringFromString:label.text
													 withBasePointSize:mid - 1.0
														   scaleFactor:scale] size].width;
		}
		
		if (difference < 0) {
			tempMax = mid - 1;
		} else if (difference > 0) {
			tempMin = mid + 1;
		} else {
			if (optSize != NULL) {
				*optSize = mid - 1.0;
			}
			return [[TRSViewCommons attributedGradeStringFromString:label.text
													 withBasePointSize:mid - 1.0
														   scaleFactor:scale] size].width;
		}
	}
	if (optSize != NULL) {
		*optSize = mid - 1.0;
	}
	return [[TRSViewCommons attributedGradeStringFromString:label.text
											 withBasePointSize:mid - 1.0
												   scaleFactor:scale] size].width;
}

+ (NSAttributedString *)attributedGradeStringFromString:(NSString *)unformatted
									  withBasePointSize:(CGFloat)pointSize
											scaleFactor:(CGFloat)scale
											 firstColor:(UIColor *)firstColor
											secondColor:(UIColor *)secondColor
												   font:(UIFont *)font {
	CGFloat smallerSize = pointSize * scale;
	
	NSDictionary *firstAttributes = @{NSFontAttributeName: [font fontWithSize:pointSize],
									  NSForegroundColorAttributeName: firstColor};
	NSDictionary *secondAttributes = @{NSFontAttributeName: [font fontWithSize:smallerSize],
									   NSForegroundColorAttributeName: secondColor};
	NSAttributedString *retVal;
	if (scale != 1.0 && unformatted.length >= 4) {
		NSMutableAttributedString *firstPart = [[NSMutableAttributedString alloc] initWithString:[unformatted substringToIndex:4]
																 attributes:firstAttributes];
		NSAttributedString *secondPart = [[NSAttributedString alloc] initWithString:[unformatted substringFromIndex:4]
													 attributes:secondAttributes];
		[firstPart appendAttributedString:secondPart];
		retVal = [[NSAttributedString alloc] initWithAttributedString:firstPart];
	} else {
		retVal = [[NSAttributedString alloc] initWithString:unformatted attributes:firstAttributes];
	}
 
	return retVal;
}

+ (NSAttributedString *)attributedGradeStringFromString:(NSString *)unformatted
									  withBasePointSize:(CGFloat)pointSize
											scaleFactor:(CGFloat)scale {
	return [TRSViewCommons attributedGradeStringFromString:unformatted
											withBasePointSize:pointSize
												  scaleFactor:scale
												   firstColor:[UIColor blackColor]
												  secondColor:[UIColor blackColor]
														 font:[UIFont systemFontOfSize:12.0]];
}

@end
