#import "NSNumber+TRSRating.h"

@implementation NSNumber (TRSRating)

- (NSNumber *)trs_integralPart {
    return [NSNumber numberWithInteger:self.integerValue];
}

- (NSNumber *)trs_fractionalPart {
    NSDecimal fractionalDecimal;
    NSDecimal leftDecimalValue = self.decimalValue;
    NSDecimal rightDecimalValue = [self trs_integralPart].decimalValue;

    NSDecimalSubtract(&fractionalDecimal, &leftDecimalValue, &rightDecimalValue, NSRoundPlain);

    return [NSDecimalNumber decimalNumberWithDecimal:fractionalDecimal];
}

@end
