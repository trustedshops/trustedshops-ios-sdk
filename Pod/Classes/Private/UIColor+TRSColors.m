#import "UIColor+TRSColors.h"

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

+ (UIColor *)trs_ananas {
	return [UIColor colorWithRed:255.0 / 255.0 green:220.0 / 255.0 blue:15.0 / 255.0 alpha:1.0];
}

+ (UIColor *)trs_kiwi {
	return [UIColor colorWithRed:204.0 / 255.0 green:227.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
}

+ (UIColor *)trs_curacao {
	return [UIColor colorWithRed:13.0 / 255.0 green:190.0 / 255.0 blue:220.0 / 255.0 alpha:1.0];
}

+ (UIColor *)trs_beere {
	return [UIColor colorWithRed:210.0 / 255.0 green:0.0 / 255.0 blue:120.0 / 255.0 alpha:1.0];
}

+ (UIColor *)trs_black {
	return [UIColor blackColor];
}

+ (UIColor *)trs_80_gray {
	return [UIColor colorWithRed:84.0 / 255.0 green:86.0 / 255.0 blue:81.0 / 255.0 alpha:1.0];
}

+ (UIColor *)trs_60_gray {
	return [UIColor colorWithRed:135.0 / 255.0 green:135.0 / 255.0 blue:128.0 / 255.0 alpha:1.0];
}

+ (UIColor *)trs_white {
	return [UIColor whiteColor];
}

- (NSString *)hexString {
	CGFloat red, green, blue, alpha;
	
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	
	return [NSString stringWithFormat:@"%02lx%02lx%02lx",
			(long)(255.0 * red), (long)(255.0 * green), (long)(255.0 * blue)];
}

@end
