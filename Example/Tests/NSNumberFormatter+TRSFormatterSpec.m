//
//  NSNumberFormatter+TRSFormatterSpec.m
//  Trustbadge
//
//  Taken up by Gero Herkenrath on 22/03/16.
//

#import "NSNumberFormatter+TRSFormatter.h"
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>


SpecBegin(NSNumberFormatter_TRSFormatter)

describe(@"NSNumberFormatter+TRSFormatter", ^{

    __block NSNumberFormatter *formatter;
	__block NSNumberFormatter *reviewFormatter;
    __block NSNumber *rating;
	__block NSNumber *reviewCount;
    beforeAll(^{
        formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
		reviewFormatter = [NSNumberFormatter trs_reviewCountFormatter];
        rating = @4.42;
		reviewCount = @1344;
    });

    afterAll(^{
        formatter = nil;
		reviewFormatter = nil;
        rating = nil;
		reviewCount = nil;
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

	describe(@"+trs_reviewCountFormatter", ^{
		
		it(@"returns a `NSNumberFormatter` object", ^{
			expect(reviewFormatter).to.beKindOf([NSNumberFormatter class]);
		});
		
		it(@"returns the same `NSNumberFormatter` object", ^{
			NSNumberFormatter *otherFormatter = [NSNumberFormatter trs_reviewCountFormatter];
			expect(reviewFormatter).to.equal(otherFormatter);
		});
		
		it(@"it uses a `.` as a group seperator", ^{
			expect([reviewFormatter stringFromNumber:reviewCount]).to.equal(@"1.344");
		});
				
	});
});

SpecEnd
