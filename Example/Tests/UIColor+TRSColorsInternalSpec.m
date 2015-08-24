#import "UIColor+TRSColorsInternal.h"
#import <Specta/Specta.h>


SpecBegin(UIColor_TRSColorsInternal)

describe(@"UIColor+TRSColorsInternal", ^{

    sharedExamplesFor(@"a UIColor object", ^(NSDictionary *data) {

        it(@"returns an UIColor object", ^{
            expect(data[@"object"]).to.beKindOf([UIColor class]);
        });

    });

    describe(@"trs_ananas", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_ananas]};
        });

        it(@"returns the CI color 'ananas'", ^{
            expect([UIColor trs_ananas]).to.equal([UIColor colorWithRed:1 green:0.862 blue:0.058 alpha:1]);
        });

    });

    describe(@"trs_kiwi", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_kiwi]};
        });

        it(@"returns the CI color 'kiwi'", ^{
            expect([UIColor trs_kiwi]).to.equal([UIColor colorWithRed:0.8 green:0.89 blue:0 alpha:1]);
        });

    });

    describe(@"trs_curacao", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_curacao]};
        });

        it(@"returns the CI color 'curacao'", ^{
            expect([UIColor trs_curacao]).to.equal([UIColor colorWithRed:0.05 green:0.745 blue:0.862 alpha:1]);
        });

    });

    describe(@"trs_beere", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_beere]};
        });

        it(@"returns the CI color 'beere'", ^{
            expect([UIColor trs_beere]).to.equal([UIColor colorWithRed:0.824 green:0 blue:0.471 alpha:1]);
        });

    });

    describe(@"trs_black", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_black]};
        });

        it(@"returns the CI color 'black'", ^{
            expect([UIColor trs_black]).to.equal([UIColor blackColor]);
        });

    });

    describe(@"trs_80_gray", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_80_gray]};
        });

        it(@"returns the CI color 'gray' with 80 percent", ^{
            expect([UIColor trs_80_gray]).to.equal([UIColor colorWithRed:0.329 green:0.337 blue:0.317 alpha:1]);
        });

    });

    describe(@"trs_60_gray", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_60_gray]};
        });

        it(@"returns the CI color 'gray' with 60 percent", ^{
            expect([UIColor trs_60_gray]).to.equal([UIColor colorWithRed:0.529 green:0.529 blue:0.501 alpha:1]);
        });

    });

    describe(@"trs_white", ^{

        itShouldBehaveLike(@"a UIColor object", ^{
            return @{@"object" : [UIColor trs_white]};
        });

        it(@"returns the CI color 'white'", ^{
            expect([UIColor trs_white]).to.equal([UIColor whiteColor]);
        });

    });

});

SpecEnd
