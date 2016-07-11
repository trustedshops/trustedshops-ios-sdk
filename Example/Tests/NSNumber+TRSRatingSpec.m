//
//  NSNumber+TRSRatingSpec.m
//  Trustbadge
//
//  Taken up by Gero Herkenrath on 22/03/16.
//

#import "NSNumber+TRSRating.h"
#import <Specta/Specta.h>


SpecBegin(NSNumber_TRSRating)

describe(@"NSNumber+TRSRating", ^{

    __block NSNumber *number;
    beforeAll(^{
        number = [NSNumber numberWithFloat:3.48];
    });

    describe(@"-trs_integralPart", ^{

        it(@"returns the integral part", ^{
            expect([number trs_integralPart]).to.equal(@3);
        });

    });

    describe(@"-trs_fractionalPart", ^{

        it(@"returns the fractional part", ^{
            expect([number trs_fractionalPart]).to.equal(@0.48);
        });

    });

});

SpecEnd
