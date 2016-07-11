//
//  TRSSingleStarViewSpec.m
//  (formerly TRSStarViewSpec.m)
//  Trustbadge
//
//  Taken up by Gero Herkenrath on 20/06/16.
//

#import "TRSSingleStarView.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Expecta_Snapshots/EXPMatchers+FBSnapshotTest.h>

#define TRSSingleStarViewRecordSnapshot 0

@interface TRSSingleStarView (PrivateTests)

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end

SpecBegin(TRSSingleStarView)

describe(@"TRSSingleStarView", ^{
	
	describe(@"+filledStarWithSidelength:", ^{
		
		it(@"returns a filled star", ^{
			TRSSingleStarView *view = [TRSSingleStarView filledStarWithSidelength:64.0]; // just use a random length for now
			expect(view).to.beKindOf([TRSSingleStarView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSSingleStarViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
		});
	});
	
	describe(@"+emptyStarWithSidelength:", ^{
		
		it(@"returns an empty star", ^{
			TRSSingleStarView *view = [TRSSingleStarView emptyStarWithSidelength:64.0]; // just use a random length for now
			expect(view).to.beKindOf([TRSSingleStarView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSSingleStarViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
		});
	});
	
	describe(@"+starWithSidelength:percentFilled:", ^{
		
		it(@"returns a star with given percent filled", ^{
			TRSSingleStarView *view = [TRSSingleStarView starWithSidelength:64.0 percentFilled:@3.78]; // just use a random length for now
			expect(view).to.beKindOf([TRSSingleStarView class]);
#if TARGET_IPHONE_SIMULATOR
#if TRSSingleStarViewRecordSnapshot
			expect(view).to.recordSnapshot();
#else
			expect(view).to.haveValidSnapshot();
#endif
#endif
		});
	});
	
	describe(@"-initWithFrame:percentFilled:", ^{
		
		it(@"accepts nil or percent values out of bounds and corrects them", ^{
			CGRect testFrame = CGRectMake(0.0, 0.0, 64.0, 64.0);
			TRSSingleStarView *nilTest = [[TRSSingleStarView alloc] initWithFrame:testFrame percentFilled:nil];
			TRSSingleStarView *tooLarge = [[TRSSingleStarView alloc] initWithFrame:testFrame percentFilled:@2.5];
			TRSSingleStarView *tooSmall = [[TRSSingleStarView alloc] initWithFrame:testFrame percentFilled:@-2.9];
			expect([nilTest.percentFilled doubleValue]).to.equal(1.0);
			expect([tooLarge.percentFilled doubleValue]).to.equal(1.0);
			expect([tooSmall.percentFilled doubleValue]).to.equal(0.0);
			
			// also test for correct class fwiw
			expect(nilTest).to.beKindOf([TRSSingleStarView class]);
			expect(tooLarge).to.beKindOf([TRSSingleStarView class]);
			expect(tooSmall).to.beKindOf([TRSSingleStarView class]);
		});
	});
	
	describe(@"-initWithFrame:", ^{
		
		it(@"returns a filled star", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
			TRSSingleStarView *view = [[TRSSingleStarView alloc] initWithFrame:frame];
			expect(view.percentFilled.doubleValue).to.equal(1.0);
		});
	});
	
	describe(@"-encodeWithCoder: and -initWithCoder:", ^{
		
		it(@"properly encodes all properties", ^{
			UIColor *activeC = [UIColor blueColor];
			UIColor *inactiveC = [UIColor greenColor];
			NSNumber *myPerc = @0.76;
			
			TRSSingleStarView *view = [TRSSingleStarView starWithSidelength:64.0 percentFilled:myPerc];
			view.activeStarColor = activeC;
			view.inactiveStarColor = inactiveC;
			NSMutableData *storage = [NSMutableData new];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:storage];
			[view encodeWithCoder:archiver];
			[archiver finishEncoding];
			view = nil;
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:storage];
			TRSSingleStarView *unpacked = [[TRSSingleStarView alloc] initWithCoder:unarchiver];
			
			expect(unpacked.activeStarColor).to.equal(activeC);
			expect(unpacked.inactiveStarColor).to.equal(inactiveC);
			expect(unpacked.percentFilled).to.equal(myPerc);
		});
	});
	
	describe(@"-sizeThatFits:", ^{
		
		it(@"returns a minimum size of 10.0 x 10.0", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 8.0, 9.0);
			TRSSingleStarView *view = [[TRSSingleStarView alloc] initWithFrame:frame percentFilled:@0.78];
			CGSize tooSmall = frame.size;
			CGSize fittingSize = [view sizeThatFits:tooSmall];
			[view sizeToFit];
			expect(fittingSize.width).to.equal(10.0);
			expect(fittingSize.height).to.equal(fittingSize.width);
		});
		
		it(@"returns a square with the larger value of width and height", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
			TRSSingleStarView *view = [[TRSSingleStarView alloc] initWithFrame:frame percentFilled:@0.78];
			CGSize nosquare = CGSizeMake(30.0, 35.0);
			CGSize squared = [view sizeThatFits:nosquare];
			expect(squared.width).to.equal(35.0);
			expect(squared.width).to.equal(squared.height);
		});
	});

	describe(@"-intrinsicContentSize", ^{
		
		it(@"returns the bounds of the view", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 10.0, 9.0);
			TRSSingleStarView *view = [[TRSSingleStarView alloc] initWithFrame:frame percentFilled:@0.78];
			CGSize intrSize = [view intrinsicContentSize];
			expect(intrSize.width).to.equal(view.bounds.size.width);
			expect(intrSize.height).to.equal(view.bounds.size.height);
		});
	});
});

SpecEnd
