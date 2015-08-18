#import "NSNumberFormatter+TRSFormatter.h"
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>


SpecBegin(NSNumberFormatter_TRSFormatter)

describe(@"NSNumberFormatter+TRSFormatter", ^{

    __block NSNumberFormatter *formatter;
    __block NSNumber *rating;
    beforeAll(^{
        formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
        rating = @4.42;
    });

    afterAll(^{
        formatter = nil;
        rating = nil;
    });

    describe(@"+trs_trustbadgeRatingFormatter", ^{

        it(@"returns a `NSNumberFormatter` object", ^{
            expect(formatter).to.beKindOf([NSNumberFormatter class]);
        });

        it(@"returns the same `NSNumberFormatter` object", ^{
            NSNumberFormatter *otherFormatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
            expect(formatter).to.equal(otherFormatter);
        });

        it(@"it uses a `.` as a decimal seperator", ^{
            expect([formatter stringFromNumber:rating]).to.equal(@"4.42");
        });

        it(@"it formats the number with one integer digit", ^{
            NSString *formattedNumberString = [[[formatter stringFromNumber:rating] componentsSeparatedByString:@"."] firstObject];
            expect(formattedNumberString).to.equal(@"4");
        });

        it(@"it formats the number with two fraction digits", ^{
            NSString *formattedNumberString = [[[formatter stringFromNumber:rating] componentsSeparatedByString:@"."] lastObject];
            expect(formattedNumberString).to.equal(@"42");
        });

    });

});

SpecEnd
