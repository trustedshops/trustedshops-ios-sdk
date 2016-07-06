//
//  TRSStarsViewSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 21/06/16.
//

#import "TRSStarsView.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Expecta_Snapshots/EXPMatchers+FBSnapshotTest.h>

#define TRSStarsViewRecordSnapshot 0

@interface TRSStarsView (PrivateTests)

- (instancetype)initWithCoder:(NSCoder *)coder;

@end

SpecBegin(TRSStarsView)

describe(@"TRSStarsView", ^{
	
	describe(@"+starsWithRating:", ^{
		
		context(@"completely filled", ^{
		
			it(@"returns five filled stars", ^{
				TRSStarsView *view = [TRSStarsView starsWithRating:@5.0];
				expect(view).to.beKindOf([TRSStarsView class]);
				expect(view.rating.doubleValue).to.equal(5.0);
#if TARGET_IPHONE_SIMULATOR
#if TRSStarsViewRecordSnapshot
				expect(view).to.recordSnapshot();
#else
				expect(view).to.haveValidSnapshot();
#endif
#endif
			});
		});
		
		context(@"completely empty", ^{
			
			it(@"returns an empty star", ^{
				TRSStarsView *view = [TRSStarsView starsWithRating:@0.0];
				expect(view).to.beKindOf([TRSStarsView class]);
				expect(view.rating.doubleValue).to.equal(0.0);
#if TARGET_IPHONE_SIMULATOR
#if TRSStarsViewRecordSnapshot
				expect(view).to.recordSnapshot();
#else
				expect(view).to.haveValidSnapshot();
#endif
#endif
			});
		});
		
		context(@"partially filled", ^{
			
			it(@"returns a star with given percent filled", ^{
				TRSStarsView *view = [TRSStarsView starsWithRating:@3.96];
				expect(view).to.beKindOf([TRSStarsView class]);
				expect(view.rating).to.equal(@3.96);
#if TARGET_IPHONE_SIMULATOR
#if TRSStarsViewRecordSnapshot
				expect(view).to.recordSnapshot();
#else
				expect(view).to.haveValidSnapshot();
#endif
#endif
			});
		});
	});
	
	describe(@"-initWithFrame:rating:", ^{
		
		it(@"accepts nil or rating values out of bounds and corrects them", ^{
			CGRect testFrame = CGRectMake(0.0, 0.0, 100.0, 20.0);
			TRSStarsView *nilTest = [[TRSStarsView alloc] initWithFrame:testFrame rating:nil];
			TRSStarsView *tooLarge = [[TRSStarsView alloc] initWithFrame:testFrame rating:@6.5];
			TRSStarsView *tooSmall = [[TRSStarsView alloc] initWithFrame:testFrame rating:@-2.9];
			expect(nilTest.rating.doubleValue).to.equal(5.0);
			expect(tooLarge.rating.doubleValue).to.equal(5.0);
			expect(tooSmall.rating.doubleValue).to.equal(0.0);
			
			// also test for correct class fwiw
			expect(nilTest).to.beKindOf([TRSStarsView class]);
			expect(tooLarge).to.beKindOf([TRSStarsView class]);
			expect(tooSmall).to.beKindOf([TRSStarsView class]);
		});
	});
	
	describe(@"-initWithFrame:", ^{
		
		it(@"returns a filled star", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 100.0, 20.0);
			TRSStarsView *view = [[TRSStarsView alloc] initWithFrame:frame];
			expect(view.rating.doubleValue).to.equal(5.0);
		});
	});
	
	describe(@"-encodeWithCoder: and -initWithCoder:", ^{
		
		it(@"properly encodes all properties", ^{
			UIColor *activeC = [UIColor blueColor];
			UIColor *inactiveC = [UIColor greenColor];
			NSNumber *myPerc = @4.76;
			
			TRSStarsView *view = [TRSStarsView starsWithRating:myPerc];
			view.activeStarColor = activeC;
			view.inactiveStarColor = inactiveC;
			NSMutableData *storage = [NSMutableData new];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:storage];
			[view encodeWithCoder:archiver];
			[archiver finishEncoding];
			view = nil;
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:storage];
			TRSStarsView *unpacked = [[TRSStarsView alloc] initWithCoder:unarchiver];
			
			expect(unpacked.activeStarColor).to.equal(activeC);
			expect(unpacked.inactiveStarColor).to.equal(inactiveC);
			expect(unpacked.rating).to.equal(myPerc);
		});
	});
	
	describe(@"-sizeThatFits:", ^{
		
		it(@"returns a minimum size of 16.0 x 16.0", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 100.0, 9.0);
			TRSStarsView *view = [[TRSStarsView alloc] initWithFrame:frame rating:@3.78];
			CGSize tooSmall = frame.size;
			CGSize fittingSize = [view sizeThatFits:tooSmall];
			[view sizeToFit];
			expect(fittingSize.height).to.equal(10.0);
			expect(fittingSize.width).to.equal(fittingSize.height * 5.0);
		});
		
		it(@"returns a rectangle with the right aspect ratio of 5 to 1", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 100.0, 18.0);
			TRSStarsView *view = [[TRSStarsView alloc] initWithFrame:frame rating:@3.76];
			CGSize nosquare = CGSizeMake(125.0, 35.0);
			CGSize squared = [view sizeThatFits:nosquare];
			expect(squared.height).to.equal(25.0);
			expect(squared.width).to.equal(squared.height * 5.0);
		});
	});
});

SpecEnd
