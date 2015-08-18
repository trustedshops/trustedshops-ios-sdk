#import "NSNumberFormatter+TRSFormatter.h"
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>


SpecBegin(NSNumberFormatter_TRSFormatter)

describe(@"NSNumberFormatter+TRSFormatter", ^{

    __block NSNumber *rating;
    beforeAll(^{
        rating = @4.42;
    });

    afterAll(^{
        rating = nil;
    });

    sharedExamplesFor(@"decimal seperator", ^(NSDictionary *data) {

        it(@"it uses a `.` as a decimal seperator", ^{
            expect(data[@"formattedNumberString"]).to.equal(@"4.42");
        });

    });

    sharedExamplesFor(@"integer digits", ^(NSDictionary *data) {

        it(@"it formats the number with one integer digit", ^{
            expect(data[@"formattedNumberString"]).to.equal(@"4");
        });

    });

    sharedExamplesFor(@"fraction digits", ^(NSDictionary *data) {

        it(@"it formats the number with two fraction digits", ^{
            expect(data[@"formattedNumberString"]).to.equal(@"42");
        });

    });

    describe(@"+trs_trustbadgeRatingFormatter", ^{

        context(@"for en_US locale", ^{

            __block id localeMock;
            before(^{
                NSLocale *usLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
                localeMock = OCMClassMock([NSLocale class]);
                OCMStub([localeMock currentLocale]).andReturn(usLocale);
            });

            after(^{
                localeMock = nil;
            });

            itShouldBehaveLike(@"decimal seperator", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : formattedNumberString};
            });

            itShouldBehaveLike(@"integer digits", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : [[formattedNumberString componentsSeparatedByString:@"."] firstObject]};
            });

            itShouldBehaveLike(@"fraction digits", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : [[formattedNumberString componentsSeparatedByString:@"."] lastObject]};
            });

        });

        context(@"for de_DE locale", ^{

            __block id localeMock;
            before(^{
                NSLocale *deLocale = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
                localeMock = OCMClassMock([NSLocale class]);
                OCMStub([localeMock currentLocale]).andReturn(deLocale);
            });

            after(^{
                localeMock = nil;
            });

            itShouldBehaveLike(@"decimal seperator", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : formattedNumberString};
            });

            itShouldBehaveLike(@"integer digits", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : [[formattedNumberString componentsSeparatedByString:@"."] firstObject]};
            });

            itShouldBehaveLike(@"fraction digits", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : [[formattedNumberString componentsSeparatedByString:@"."] lastObject]};
            });

        });

        context(@"for es_ES locale", ^{

            __block id localeMock;
            before(^{
                NSLocale *esLocale = [NSLocale localeWithLocaleIdentifier:@"es_ES"];
                localeMock = OCMClassMock([NSLocale class]);
                OCMStub([localeMock currentLocale]).andReturn(esLocale);
            });

            after(^{
                localeMock = nil;
            });

            itShouldBehaveLike(@"decimal seperator", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : formattedNumberString};
            });

            itShouldBehaveLike(@"integer digits", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : [[formattedNumberString componentsSeparatedByString:@"."] firstObject]};
            });

            itShouldBehaveLike(@"fraction digits", ^{
                NSNumberFormatter *formatter = [NSNumberFormatter trs_trustbadgeRatingFormatter];
                NSString *formattedNumberString = [formatter stringFromNumber:rating];

                return @{@"formattedNumberString" : [[formattedNumberString componentsSeparatedByString:@"."] lastObject]};
            });

        });

    });

});

SpecEnd
