#import "NSNumberFormatter+TRSFormatter.h"

@implementation NSNumberFormatter (TRSFormatter)

+ (NSNumberFormatter *)trs_trustbadgeRatingFormatter {
    static NSNumberFormatter *decimalFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decimalFormatter = [[NSNumberFormatter alloc] init];
        decimalFormatter.minimumIntegerDigits = 1;
        decimalFormatter.minimumFractionDigits = 2;
        decimalFormatter.maximumFractionDigits = 2;
        decimalFormatter.decimalSeparator = @".";
    });

    return decimalFormatter;
}

@end
