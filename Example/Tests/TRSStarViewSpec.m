#import "TRSStarView.h"
#import <Expecta/Expecta.h>
//#import <Expecta_Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <Specta/Specta.h>


SpecBegin(TRSStarView)

describe(@"TRSStarView", ^{

    describe(@"+filledStarWithSize", ^{

        it(@"returns a filled star", ^{
            TRSStarView *view = [TRSStarView filledStarWithSize:CGSizeMake(64.0f, 64.0f)];
			expect(view).to.beKindOf([TRSStarView class]);
//             expect(view).to.recordSnapshot();
//            expect(view).to.haveValidSnapshot();
        });

    });

    describe(@"+emptyStarWithSize", ^{

        it(@"returns an empty star", ^{
            TRSStarView *view = [TRSStarView emptyStarWithSize:CGSizeMake(64.0f, 64.0f)];
			expect(view).to.beKindOf([TRSStarView class]);
//             expect(view).to.recordSnapshot();
//            expect(view).to.haveValidSnapshot();
        });

    });

    describe(@"-initWithSize:percentFilled:", ^{

        it(@"returns a half-filled star", ^{
            TRSStarView *view = [[TRSStarView alloc ] initWithSize:CGSizeMake(64.0f, 64.0f) percentFilled:@0.5];
			expect(view).to.beKindOf([TRSStarView class]);
//             expect(view).to.recordSnapshot();
//            expect(view).to.haveValidSnapshot();
        });

    });

});

SpecEnd
