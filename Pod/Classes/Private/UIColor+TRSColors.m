#import "UIColor+TRSColors.h"
#import "UIColor+TRSColorsInternal.h"

@implementation UIColor (TRSColors)

+ (UIColor *)trs_filledStarColor {
    return [UIColor trs_ananas];
}

+ (UIColor *)trs_nonFilledStarColor {
    return [UIColor trs_60_gray];
}

+ (UIColor *)trs_backgroundStarColor {
    return [UIColor trs_white];
}

+ (UIColor *)trs_trustbadgeBorderColor {
    return [UIColor trs_ananas];
}

- (NSString *)hexString {
	CGFloat red, green, blue, alpha;
	
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	
	return [NSString stringWithFormat:@"%02lx%02lx%02lx",
			(long)(255.0 * red), (long)(255.0 * green), (long)(255.0 * blue)];
}

@end
