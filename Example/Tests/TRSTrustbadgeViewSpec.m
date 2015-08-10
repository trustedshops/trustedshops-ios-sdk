#import "TRSTrustbadgeView.h"
#import <Specta/Specta.h>


SpecBegin(TRSTrustbadgeView)

describe(@"TRSTrustbadgeView", ^{

    describe(@"-initWithTrustedShopsID:", ^{

        context(@"with a valid Trusted Shops ID", ^{

            __block TRSTrustbadgeView *view;
            beforeEach(^{
                view = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"999888777666555444333222111000999"];
            });

            afterEach(^{
                view = nil;
            });

            it(@"returns a `TRSTrustbadgeView` object", ^{
                expect(view).to.beKindOf([TRSTrustbadgeView class]);
            });

            it(@"retruns the same ID", ^{
                expect(view.trustedShopsID).to.equal(@"999888777666555444333222111000999");
            });

        });

        context(@"with an unknown Trusted Shops ID", ^{
        });

        context(@"with an invalid Trusted Shops ID", ^{
        });

    });

});

SpecEnd
