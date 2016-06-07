#import "TRSStarView.h"
#import <Expecta/Expecta.h>
#import <Expecta_Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <Specta/Specta.h>

#define TRSStarViewRecordSnapshot 0

SpecBegin(TRSStarView)

describe(@"TRSStarView", ^{

    describe(@"+filledStarWithSize", ^{

        it(@"returns a filled star", ^{
            TRSStarView *view = [TRSStarView filledStarWithSize:CGSizeMake(64.0f, 64.0f)];
			expect(view).to.beKindOf([TRSStarView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSStarViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
        });

    });

    describe(@"+emptyStarWithSize", ^{

        it(@"returns an empty star", ^{
            TRSStarView *view = [TRSStarView emptyStarWithSize:CGSizeMake(64.0f, 64.0f)];
			expect(view).to.beKindOf([TRSStarView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSStarViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
        });

    });

    describe(@"-initWithSize:percentFilled:", ^{

        it(@"returns a half-filled star", ^{
            TRSStarView *view = [[TRSStarView alloc ] initWithSize:CGSizeMake(64.0f, 64.0f) percentFilled:@0.5];
			expect(view).to.beKindOf([TRSStarView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSStarViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
        });

    });

});

SpecEnd
