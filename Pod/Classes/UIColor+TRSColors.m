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

@end
