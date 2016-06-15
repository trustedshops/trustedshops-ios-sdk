//
//  UIColor+TRSColorsSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 07/04/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "UIColor+TRSColors.h"
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

	describe(@"trs_ananas", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_ananas]};
		});
		
		it(@"returns the CI color 'ananas'", ^{
			expect([UIColor trs_ananas]).to.equal([UIColor colorWithRed:255.0 / 255.0 green:220.0 / 255.0 blue:15.0 / 255.0 alpha:1.0]);
		});
		
	});
	
	describe(@"trs_kiwi", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_kiwi]};
		});
		
		it(@"returns the CI color 'kiwi'", ^{
			expect([UIColor trs_kiwi]).to.equal([UIColor colorWithRed:204.0 / 255.0 green:227.0 / 255.0 blue:0.0 / 255.0 alpha:1.0]);
		});
		
	});
	
	describe(@"trs_curacao", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_curacao]};
		});
		
		it(@"returns the CI color 'curacao'", ^{
			expect([UIColor trs_curacao]).to.equal([UIColor colorWithRed:13.0 / 255.0 green:190.0 / 255.0 blue:220.0 / 255.0 alpha:1.0]);
		});
		
	});
	
	describe(@"trs_beere", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_beere]};
		});
		
		it(@"returns the CI color 'beere'", ^{
			expect([UIColor trs_beere]).to.equal([UIColor colorWithRed:210.0 / 255.0 green:0.0 / 255.0 blue:120.0 / 255.0 alpha:1.0]);
		});
		
	});
	
	describe(@"trs_black", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_black]};
		});
		
		it(@"returns the CI color 'black'", ^{
			expect([UIColor trs_black]).to.equal([UIColor blackColor]);
		});
		
	});
	
	describe(@"trs_80_gray", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_80_gray]};
		});
		
		it(@"returns the CI color 'gray' with 80 percent", ^{
			expect([UIColor trs_80_gray]).to.equal([UIColor colorWithRed:84.0 / 255.0 green:86.0 / 255.0 blue:81.0 / 255.0 alpha:1.0]);
		});
		
	});
	
	describe(@"trs_60_gray", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_60_gray]};
		});
		
		it(@"returns the CI color 'gray' with 60 percent", ^{
			expect([UIColor trs_60_gray]).to.equal([UIColor colorWithRed:135.0 / 255.0 green:135.0 / 255.0 blue:128.0 / 255.0 alpha:1.0]);
		});
		
	});
	
	describe(@"trs_white", ^{
		
		itShouldBehaveLike(@"a UIColor object", ^{
			return @{@"object" : [UIColor trs_white]};
		});
		
		it(@"returns the CI color 'white'", ^{
			expect([UIColor trs_white]).to.equal([UIColor whiteColor]);
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
