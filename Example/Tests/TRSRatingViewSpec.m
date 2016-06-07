#import "TRSRatingView.h"
#import <Expecta/Expecta.h>
#import <Expecta_Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <Specta/Specta.h>

#define TRSRatingViewRecordSnapshot 0

SpecBegin(TRSRatingView)

describe(@"TRSRatingView", ^{

    describe(@"-initWithFrame:rating:", ^{

		it(@"returns an initialized object", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@1];
            expect(view).toNot.beNil();
			expect(view).to.beKindOf([TRSRatingView class]);
        });


        it(@"returns a view with non stars", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@0];
			expect(view).to.beKindOf([TRSRatingView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSRatingViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
        });

        it(@"returns a view with two and a half stars", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@2.5];
			expect(view).to.beKindOf([TRSRatingView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSRatingViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
        });

        it(@"returns a view with five stars", ^{
            TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@5];
			expect(view).to.beKindOf([TRSRatingView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSRatingViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
        });

    });
	
	describe(@"-intrinsicContentSIze", ^{
		it(@"simply returns the size of bounds", ^{
			TRSRatingView *view = [[TRSRatingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 32.0f) rating:@1];
			CGSize target = view.bounds.size;
			CGSize result = [view intrinsicContentSize];
			expect(CGSizeEqualToSize(target, result)).to.beTruthy();
		});
	});

});

SpecEnd
