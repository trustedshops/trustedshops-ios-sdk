//
//  TRSProductRatingViewSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 07/07/16.
//

#import "TRSProductRatingView.h"
#import "TRSProductBaseView+Private.h"
#import "TRSPrivateBasicDataView+Private.h"
#import "TRSStarsView.h"
#import "TRSErrors.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>

@interface TRSProductRatingView (PrivateTests)

@property (nonatomic, strong) UILabel *gradeLabel;
@property (nonatomic, copy) NSString *oneLineString;
@property (nonatomic, copy) NSString *twoLineString;

// these come from the superclass (TRSProductSimpleRatingView)
@property (nonatomic, strong) TRSStarsView *stars;
@property (nonatomic, strong) UIView *starsPlaceholder;

- (CGRect)frameForGrade;
- (CGRect)frameForStars;
- (NSTextAlignment)actualAlignment;

@end


SpecBegin(TRSProductRatingView)

describe(@"-encodeWithCoder: and -initWithCoder:", ^{
	
	it(@"properly encodes all properties", ^{
		CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
		TRSProductRatingView *view = [[TRSProductRatingView alloc] initWithFrame:frame
																  trustedShopsID:@"anID"
																		apiToken:@"aToken"
																			 SKU:@"20610"];
		
		view.debugMode = YES;
		view.useOnlyOneLine = YES;
		NSMutableData *storage = [NSMutableData new];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:storage];
		[view encodeWithCoder:archiver];
		[archiver finishEncoding];
		view = nil;
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:storage];
		TRSProductRatingView *unpacked = [[TRSProductRatingView alloc] initWithCoder:unarchiver];
		
		expect(unpacked.debugMode).to.beTruthy();
		expect(unpacked.useOnlyOneLine).to.beTruthy();
	});
});

context(@"sizing and drawing", ^{
	
	describe(@"-sizeThatFits", ^{
		
		it(@"returns a minimum size for too small input", ^{
			CGSize input = CGSizeMake(5.0, 5.0);
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductRatingView *view = [[TRSProductRatingView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			// important: give the view a fake label to work with!
			UILabel *fake = [UILabel new];
			// use a long ass label to catch all cases
			fake.text = NSLocalizedString(@"4.89/5.00 (312.123.344 Bewertungen)", @"used in unit tests, do not localize");
			view.gradeLabel = fake;
			
			CGSize output = [view sizeThatFits:input];
			expect(output.height).to.equal(20.0);
			expect(output.width).to.beCloseToWithin(145.0, 2.0); // result of the text width, so I am rough here
			
			// for one line mode:
			view.useOnlyOneLine = YES;
			view.gradeLabel.text = view.oneLineString;
			output = [view sizeThatFits:input];
			expect(output.height).to.equal(10.0);
			expect(output.width).to.beCloseToWithin(20.0 * 5.0, 5.0); // result of the text width, so I am rough here
		});
		
	});
	
	describe(@"-layoutSubviews", ^{
		
		// note: I know this is not supposed to be called directly, but this is just a test
		// I might rework this in the future and embedd the view in a real view hierarchy, but for now this is enough.
		it(@"calls frameForGrade to djust the label", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductRatingView *view = [[TRSProductRatingView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			view.debugMode = YES;
			TRSStarsView *fakeStars = [[TRSStarsView alloc] initWithRating:@5]; // we need this
			view.stars = fakeStars;
			id viewMock = OCMPartialMock(view);
			OCMStub([viewMock frameForGrade]).andForwardToRealObject();
			
			// try one line mode first:
			[viewMock setUseOnlyOneLine:YES];
			OCMExpect([viewMock frameForGrade]);
			[viewMock layoutSubviews];
			OCMVerify([viewMock frameForGrade]);
			
			// same for two line mode
			[viewMock setUseOnlyOneLine:NO];
			OCMExpect([viewMock frameForGrade]);
			[viewMock layoutSubviews];
			OCMVerify([viewMock frameForGrade]);
		});
	});
	
	
});

context(@"alignment features", ^{
	
	// the setter for useOnlyOneLine is tested indirectly in other methods already
	describe(@"-setAlignment:", ^{
		
		it(@"changes the label alignment in two line mode", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductRatingView *view = [[TRSProductRatingView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			view.debugMode = YES;
			view.useOnlyOneLine = YES;
			NSTextAlignment viewAlignment = view.alignment;
			NSTextAlignment labelAlignment = view.gradeLabel.textAlignment;
			// test init values in this state
			expect(viewAlignment).to.equal(NSTextAlignmentNatural);
			expect(labelAlignment).to.equal(NSTextAlignmentCenter);
			// change alignment
			view.alignment = NSTextAlignmentRight;
			expect(view.alignment).toNot.equal(viewAlignment);
			expect(view.gradeLabel.textAlignment).to.equal(labelAlignment); // unchanged!
			view.useOnlyOneLine = NO;
			view.alignment = NSTextAlignmentCenter;
			expect(view.gradeLabel.textAlignment).to.equal(view.alignment);
		});
		
	});
	
	describe(@"-frameForStars and -frameForGrade", ^{
		
		it(@"deliver different rects for left, center, and right alignment", ^{
			
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductRatingView *view = [[TRSProductRatingView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			view.debugMode = YES;
			UILabel *fakeLabel = [UILabel new];
			fakeLabel.text = view.twoLineString;
			view.gradeLabel = fakeLabel;
			
			// I won't test one line mode, because the only difference is an offset...
			CGRect originalStars = [view frameForStars];
			CGRect originalLabel = [view frameForGrade];
			view.alignment = NSTextAlignmentCenter;
			CGRect centerStars = [view frameForStars];
			CGRect centerLabel = [view frameForGrade];
			view.alignment = NSTextAlignmentRight;
			CGRect rightStars = [view frameForStars]; // the stars are aligned right! Cthulhu is coming! Ia! Ia! R'lyeh! Cthulhu fhtagn!
			CGRect rightLabel = [view frameForGrade];
			
			expect(originalStars).toNot.equal(centerStars);
			expect(originalStars).toNot.equal(rightStars);
			expect(centerStars).toNot.equal(rightStars);
			
			expect(originalLabel).toNot.equal(centerLabel);
			expect(originalLabel).toNot.equal(rightLabel);
			expect(centerLabel).toNot.equal(rightLabel);
		});
		
	});
	
	describe(@"-actualAlignment", ^{
		
		it(@"returns right alignment for default if UI demands it", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductRatingView *view = [[TRSProductRatingView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			view.debugMode = YES;

			id mockUIView = OCMClassMock([UIView class]);
			OCMStub([mockUIView userInterfaceLayoutDirectionForSemanticContentAttribute:view.semanticContentAttribute])
			.andReturn(UIUserInterfaceLayoutDirectionRightToLeft);
			
			expect([view actualAlignment]).to.equal(NSTextAlignmentRight);
			
		});
		
	});
	
});

context(@"helper methods", ^{
	
	describe(@"-finishLoading", ^{
		
		it(@"creates a TRSSTarsView", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductRatingView *view = [[TRSProductRatingView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			view.debugMode = YES;
			view.overallMark = @4.83;
			NSString *unitS = TRSLocalizedString(@"Review", @"Used in the shop grading views' grade label (plural)");
			NSString *unitP = TRSLocalizedString(@"Reviews", @"Used in the shop grading views' grade label (plural)");
			NSString *twoLineComparisonSingular = [NSString stringWithFormat:@"4.83/5.00 (1 %@)", unitS];
			NSString *twoLineComparisonPlural = [NSString stringWithFormat:@"4.83/5.00 (1.344 %@)", unitP];
			
			// for one review:
			view.totalReviewCount = @1;
			[view finishLoading];
			expect(view.oneLineString).to.equal(@"(1) 4.83/5.00");
			expect(view.twoLineString).to.equal(twoLineComparisonSingular);
			
			// for 1344 reviews:
			view.totalReviewCount = @1344;
			[view finishLoading];
			expect(view.oneLineString).to.equal(@"(1.344) 4.83/5.00");
			expect(view.twoLineString).to.equal(twoLineComparisonPlural);
			
		});
		
	});
	
});

SpecEnd
