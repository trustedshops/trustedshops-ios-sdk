//
//  TRSProductSimpleRatingViewSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 07/07/16.
//

#import "TRSProductSimpleRatingView.h"
#import "TRSProductBaseView+Private.h"
#import "TRSPrivateBasicDataView+Private.h"
#import "TRSStarsView.h"
#import "TRSErrors.h"
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>

@interface TRSProductSimpleRatingView (PrivateTests)

@property (nonatomic, strong) TRSStarsView *stars;
@property (nonatomic, strong) UIView *starsPlaceholder;

@end


SpecBegin(TRSProductSimpleRatingView)

describe(@"-encodeWithCoder: and -initWithCoder:", ^{
	
	it(@"properly encodes all properties", ^{
		CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
		TRSProductSimpleRatingView *view = [[TRSProductSimpleRatingView alloc] initWithFrame:frame
																			  trustedShopsID:@"anID"
																					apiToken:@"aToken"
																						 SKU:@"20610"];
		
		UIColor *activeColor = [UIColor blueColor];
		UIColor *inactiveColor = [UIColor greenColor];
		view.activeStarColor = activeColor;
		view.inactiveStarColor = inactiveColor;
		view.debugMode = YES;
		NSMutableData *storage = [NSMutableData new];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:storage];
		[view encodeWithCoder:archiver];
		[archiver finishEncoding];
		view = nil;
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:storage];
		TRSProductSimpleRatingView *unpacked = [[TRSProductSimpleRatingView alloc] initWithCoder:unarchiver];
		
		expect(unpacked.tsID).to.equal(@"anID");
		expect(unpacked.apiToken).to.equal(@"aToken");
		expect(unpacked.SKU).to.equal(@"20610");
		expect(unpacked.debugMode).to.beTruthy();
		expect(unpacked.activeStarColor).to.equal(activeColor);
		expect(unpacked.inactiveStarColor).to.equal(inactiveColor);
	});
});

context(@"sizing and drawing", ^{
	
	describe(@"-sizeThatFits", ^{
		
		it(@"returns a minimum size for too small input", ^{
			CGSize input = CGSizeMake(5.0, 5.0);
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductSimpleRatingView *view = [[TRSProductSimpleRatingView alloc] initWithFrame:frame
																				  trustedShopsID:@"anID"
																						apiToken:@"aToken"
																							 SKU:@"20610"];
			CGSize output = [view sizeThatFits:input];
			
			expect(output.height).to.beGreaterThanOrEqualTo(16.0);
			expect(output.width).to.beGreaterThanOrEqualTo(16.0 * 5.0);
		});
		
	});
	
	describe(@"-layoutSubviews", ^{
		
		// note: I know this is not supposed to be called directly, but this is just a test
		// I might rework this in the future and embedd the view in a real view hierarchy, but for now this is enough.
		it(@"properly adjusts the stars view", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductSimpleRatingView *view = [[TRSProductSimpleRatingView alloc] initWithFrame:frame
																				  trustedShopsID:@"anID"
																						apiToken:@"aToken"
																							 SKU:@"20610"];
			view.debugMode = YES;
			[view sizeToFit];
			TRSStarsView *fakeStars = [[TRSStarsView alloc] initWithRating:@5];
			id starsMock = OCMPartialMock(fakeStars);
			view.stars = starsMock;
			OCMExpect([starsMock setFrame:view.starsPlaceholder.bounds]);
			[view layoutSubviews];
			OCMVerifyAll(starsMock);
			// this also ensures that -frameForStars is called, but I don't explicitly test for that
		});
	});

	
});

context(@"custom setters", ^{
	
	describe(@"-setActiveColor: and -setInactiveColor:", ^{
		
		it(@"checks for starsView on color change", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductSimpleRatingView *testView = [[TRSProductSimpleRatingView alloc] initWithFrame:frame
																				  trustedShopsID:@"anID"
																						apiToken:@"aToken"
																							 SKU:@"20610"];
			testView.debugMode = YES;
			
			// give the testView a starsView without actually loading
			TRSStarsView *fakeStars = [[TRSStarsView alloc] initWithRating:@5];
			
			UIColor *defaultActive = testView.activeStarColor;
			UIColor *defaultInactive = testView.inactiveStarColor;
			id starsMock = OCMPartialMock(fakeStars);
			testView.stars = starsMock;
			OCMExpect([starsMock setInactiveStarColor:[OCMArg any]]);
			OCMExpect([starsMock setActiveStarColor:[OCMArg any]]);
			[testView setActiveStarColor:[UIColor blueColor]];
			[testView setInactiveStarColor:[UIColor greenColor]];
			
			expect(testView.activeStarColor).toNot.equal(defaultActive);
			expect(testView.inactiveStarColor).toNot.equal(defaultInactive);
			expect(testView.activeStarColor).to.equal([UIColor blueColor]);
			expect(testView.inactiveStarColor).to.equal([UIColor greenColor]);
			
			OCMVerifyAll(starsMock);
		});
		
	});

});

context(@"helper methods", ^{
	
	describe(@"-finishLoading", ^{
		
		it(@"creates a TRSSTarsView", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductSimpleRatingView *view = [[TRSProductSimpleRatingView alloc] initWithFrame:frame
																				  trustedShopsID:@"anID"
																						apiToken:@"aToken"
																							 SKU:@"20610"];
			view.overallMark = @4.83; // needed for the method to work
			
			expect(view.stars).to.beNil();
			[view finishLoading];
			expect(view.stars).toNot.beNil();
			expect(view.stars).to.beKindOf([TRSStarsView class]);
		});
		
	});
	
});

SpecEnd
