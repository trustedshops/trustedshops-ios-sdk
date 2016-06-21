#import "TRSViewCommons.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

SpecBegin(TRSViewCommons)

context(@"label width and height helpers", ^{
	
	__block UILabel *testLabel;
	__block CGFloat height;
	beforeAll(^{
		testLabel = [UILabel new];
		testLabel.text = @"This is a test";
		[testLabel sizeToFit];
		height = testLabel.bounds.size.height + 10.0; // just use some random value
	});
	afterAll(^{
		testLabel = nil;
		height = 0.0;
	});

	describe(@"+widthForLabel:withHeight:", ^{
		
		it(@"returns a CGFloat larger or equal than 0", ^{
			CGFloat retVal = [TRSViewCommons widthForLabel:testLabel withHeight:height];
			expect(retVal).to.beGreaterThanOrEqualTo(0.0);
		});
	});
	
	describe(@"+optimalHeightForFontInLabel:", ^{
		
		it(@"returns a CGFloat larger or equal than 0", ^{
			CGFloat retVal = [TRSViewCommons optimalHeightForFontInLabel:testLabel];
			expect(retVal).to.beGreaterThanOrEqualTo(0.0);
		});
	});
	
	describe(@"+widthForLabel:withHeight:optimalFontSize:", ^{
		
		it(@"returns a width greater or equal 0", ^{
			CGFloat retVal = [TRSViewCommons widthForLabel:testLabel withHeight:height];
			expect(retVal).to.beGreaterThanOrEqualTo(0.0);
		});
		
		it(@"returns a optimal font size by reference", ^{
			CGFloat willbeChanged = 11.4;
			CGFloat toCompare = 7.9;
			[TRSViewCommons widthForLabel:testLabel withHeight:height optimalFontSize:&willbeChanged];
			[TRSViewCommons widthForLabel:testLabel withHeight:height optimalFontSize:&toCompare];
			expect(willbeChanged).to.equal(toCompare);
		});
	});
	
	describe(@"+widthForLabel:withHeight:optimalFontSize:smallerCharacterScale:", ^{
		
		it(@"returns different width for different scales", ^{
			CGFloat widthOne = [TRSViewCommons widthForLabel:testLabel
												  withHeight:height
											 optimalFontSize:NULL
									  smallerCharactersScale:1.0];
			CGFloat widthTwo = [TRSViewCommons widthForLabel:testLabel
												  withHeight:height
											 optimalFontSize:NULL
									  smallerCharactersScale:0.5];
			expect(widthOne).toNot.equal(widthTwo);
		});
		
		it(@"uses a scale of 1 instead of wrong value", ^{
			CGFloat badScale = [TRSViewCommons widthForLabel:testLabel
												  withHeight:height
											 optimalFontSize:NULL
									  smallerCharactersScale:1.5];
			CGFloat oneScale = [TRSViewCommons widthForLabel:testLabel
												  withHeight:height
											 optimalFontSize:NULL
									  smallerCharactersScale:1.0];
			expect(badScale).to.equal(oneScale);
		});
		
		it(@"returns 0 and sets optSize to 0 for missing label or height of 0", ^{
			CGFloat retAsRef = 4.0;
			CGFloat normalRet = 4.0;
			// stupid height
			normalRet = [TRSViewCommons widthForLabel:testLabel
										   withHeight:0.0
									  optimalFontSize:&retAsRef
							   smallerCharactersScale:0.8];
			expect(retAsRef).to.equal(0.0);
			expect(normalRet).to.equal(0.0);
			
			retAsRef = 4.0;
			normalRet = 4.0;
			// stupid label
			normalRet = [TRSViewCommons widthForLabel:nil
										   withHeight:0.0
									  optimalFontSize:&retAsRef
							   smallerCharactersScale:0.8];
			expect(retAsRef).to.equal(0.0);
			expect(normalRet).to.equal(0.0);
		});
		
		it(@"has a min height for the font", ^{
			CGFloat optSizeRet = 50.0;
			CGFloat theWidth = [TRSViewCommons widthForLabel:testLabel
												  withHeight:9.0
											 optimalFontSize:&optSizeRet
									  smallerCharactersScale:1.0];
			expect(optSizeRet).to.beLessThanOrEqualTo(9.0); // this is hardcoded in the class
			expect(theWidth).toNot.equal(0.0);
		});
		
		it(@"returns correct values for already sized label", ^{
			[testLabel sizeToFit];
			CGFloat optSizeRet = testLabel.font.pointSize - 1.0; //hardcoded in class cause it looks better
			CGSize labelSize = testLabel.bounds.size;
			CGFloat theWidth = [TRSViewCommons widthForLabel:testLabel
												  withHeight:labelSize.height
											 optimalFontSize:&optSizeRet
									  smallerCharactersScale:1.0];
			expect(optSizeRet).to.equal(testLabel.font.pointSize - 1.0);
			expect(theWidth).toNot.equal(labelSize.width);
		});
	});
});

context(@"attributed string creation", ^{
	
	describe(@"+attributedGradeStringFromString:withBasePointSize:scaleFactor:", ^{
		
		it(@"calls attributedGradeStringFromString:withBasePointSize:scaleFactor:firstColor:secondColor:font:", ^{
			id classMock = OCMClassMock([TRSViewCommons class]);
			OCMExpect([classMock attributedGradeStringFromString:[OCMArg any]
											   withBasePointSize:13.0
													 scaleFactor:0.8
													  firstColor:[OCMArg any]
													 secondColor:[OCMArg any]
															font:[OCMArg any]]).andForwardToRealObject();
			NSAttributedString *result =
			[TRSViewCommons attributedGradeStringFromString:@"TestStringLongEnough" withBasePointSize:13.0 scaleFactor:0.8];
			expect(result).to.beKindOf([NSAttributedString class]);
			OCMVerifyAll(classMock);
		});
	});
	
	describe(@"+attributedGradeStringFromString:withBasePointSize:scaleFactor:firstColor:secondColor:font:", ^{
		
		it(@"returns a string requiring less width for smaller scale", ^{
			NSString *longString = @"I make this so long that it definitely gets shorter with a small scale...";
			NSAttributedString *stringOne = [TRSViewCommons attributedGradeStringFromString:longString
																		  withBasePointSize:17.0
																				scaleFactor:1.0
																				 firstColor:[UIColor blueColor] // don't care
																				secondColor:[UIColor greenColor] // dito
																					   font:[UIFont systemFontOfSize:13.0]];
			NSAttributedString *stringTwo = [TRSViewCommons attributedGradeStringFromString:longString
																		  withBasePointSize:17.0
																				scaleFactor:0.5
																				 firstColor:[UIColor blueColor] // don't care
																				secondColor:[UIColor greenColor] // dito
																					   font:[UIFont systemFontOfSize:13.0]];
			CGFloat widthOne = [stringOne size].width;
			CGFloat widthTwo = [stringTwo size].width;
			expect(widthTwo).to.beLessThan(widthOne);
		});
	});
});

SpecEnd
