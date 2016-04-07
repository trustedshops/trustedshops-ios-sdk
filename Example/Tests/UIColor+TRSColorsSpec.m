//
//  UIColor+TRSColorsSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 07/04/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "UIColor+TRSColors.h"
#import "UIColor+TRSColorsInternal.h"
#import <Specta/Specta.h>



SpecBegin(UIColor_TRSColors)

describe(@"UIColor+TRSColors", ^{
	
	sharedExamplesFor(@"a UIColor object", ^(NSDictionary *data) {
		
		it(@"returns an UIColor object", ^{
			expect(data[@"object"]).to.beKindOf([UIColor class]);
		});
		
	});
	
	describe(@"trs_filledStarColor", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_filledStarColor]};
		});
		
		it(@"returns the CI color 'ananas'", ^{
			expect([UIColor trs_filledStarColor]).to.equal([UIColor trs_ananas]);
		});
		
	});
	
	describe(@"trs_nonFilledStarColor", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_nonFilledStarColor]};
		});
		
		it(@"returns the CI color 'ananas'", ^{
			expect([UIColor trs_nonFilledStarColor]).to.equal([UIColor trs_60_gray]);
		});
		
	});
	
	describe(@"trs_backgroundStarColor", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_backgroundStarColor]};
		});
		
		it(@"returns the CI color 'ananas'", ^{
			expect([UIColor trs_backgroundStarColor]).to.equal([UIColor trs_white]);
		});
		
	});

	
	describe(@"trs_trustbadgeBorderColor", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_trustbadgeBorderColor]};
		});
		
		it(@"returns the CI color 'ananas'", ^{
			expect([UIColor trs_trustbadgeBorderColor]).to.equal([UIColor trs_ananas]);
		});
		
	});

	describe(@"hexString", ^{
		
		it(@"returns an NSString that's six characters long", ^{
			expect([[UIColor whiteColor] hexString]).to.beKindOf([NSString class]);
			expect([[[UIColor blackColor] hexString] length]).to.equal(6);
		});
		
		it(@"returns a valid hex string for standard colors", ^{
			expect([[UIColor whiteColor] hexString]).to.equal(@"ffffff");
			expect([[UIColor blackColor] hexString]).to.equal(@"000000");
			expect([[UIColor redColor] hexString]).to.equal(@"ff0000");
			expect([[UIColor greenColor] hexString]).to.equal(@"00ff00");
			expect([[UIColor blueColor] hexString]).to.equal(@"0000ff");
			UIColor *defaultTRSColor = [UIColor colorWithRed:(243.0 / 255.0) green:(112.0 / 255.0) blue:(0.0 / 255.0) alpha:1.0];
			expect([defaultTRSColor hexString]).to.equal(@"f37000");
			UIColor *exampleColor = [UIColor colorWithRed:(54.0 / 255.0) green:(203.0 / 255.0) blue:(118.0 / 255.0) alpha:1.0];
			expect([exampleColor hexString]).to.equal(@"36cb76");
		});
		
	});
});

SpecEnd
