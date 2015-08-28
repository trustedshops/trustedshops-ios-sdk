#import "TRSRatingView.h"
#import <Expecta/Expecta.h>
#import <Expecta_Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <Specta/Specta.h>


SpecBegin(TRSRatingView)

describe(@"TRSRatingView", ^{

    describe(@"-initWithFrame:rating:", ^{

        it(@"returns an initialized object", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@1];
            expect(view).toNot.beNil();
        });


        it(@"returns a view with non stars", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@0];
            // expect(view).to.recordSnapshot();
            expect(view).to.haveValidSnapshot();
        });

        it(@"returns a view with two and a half stars", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@2.5];
            // expect(view).to.recordSnapshot();
            expect(view).to.haveValidSnapshot();
        });

        it(@"returns a view with five stars", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@5];
            // expect(view).to.recordSnapshot();
            expect(view).to.haveValidSnapshot();
        });

    });

});

SpecEnd
