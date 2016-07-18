//
//  TRSProductReviewSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 18/07/16.
//

#import "TRSProductReview.h"
#import "TRSCriteria.h"
#import <Specta/Specta.h>

SpecBegin(TRSProductReview)

describe(@"TRSProductReview", ^{
	
	describe(@"-initWithCreationDate:comment:mark:UID:criteria:", ^{
		
		it(@"does not allow marks above 5", ^{
			TRSCriteria *testCrit = [[TRSCriteria alloc] initWithMark:@4 type:kTRSTotal];
			TRSProductReview *test = [[TRSProductReview alloc] initWithCreationDate:[NSDate date]
																			comment:@"comment"
																			   mark:@5.1
																				UID:@"blablubb"
																		   criteria:@[testCrit]];
			expect([test.mark floatValue]).to.beLessThanOrEqualTo(5.0f);
		});
		
		it(@"does not allow marks below 1", ^{
			TRSCriteria *testCrit = [[TRSCriteria alloc] initWithMark:@4 type:kTRSTotal];
			TRSProductReview *test = [[TRSProductReview alloc] initWithCreationDate:[NSDate date]
																			comment:@"comment"
																			   mark:@0.6
																				UID:@"blablubb"
																		   criteria:@[testCrit]];
			expect([test.mark floatValue]).to.beGreaterThanOrEqualTo(1.0f);
		});
		
		it(@"returns a TRSProductReview object", ^{
			TRSCriteria *testCrit = [[TRSCriteria alloc] initWithMark:@4 type:kTRSTotal];
			TRSProductReview *test = [[TRSProductReview alloc] initWithCreationDate:[NSDate date]
																			comment:@"comment"
																			   mark:@4
																				UID:@"blablubb"
																		   criteria:@[testCrit]];
			expect(test).toNot.beNil();
			expect(test).to.beKindOf([TRSProductReview class]);
		});
		
	});
	
	describe(@"-debugDescription", ^{
		
		it(@"returns an NSString", ^{
			TRSCriteria *testCrit = [[TRSCriteria alloc] initWithMark:@4 type:kTRSTotal];
			TRSProductReview *test = [[TRSProductReview alloc] initWithCreationDate:[NSDate date]
																			comment:@"comment"
																			   mark:@4
																				UID:@"blablubb"
																		   criteria:@[testCrit]];
			NSString *desc = [test debugDescription];
			expect(desc).to.beKindOf([NSString class]);
			expect([desc containsString:[NSString stringWithFormat:@"creationDate: %@", test.creationDate]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"comment: %@", test.comment]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"mark: %@", test.mark]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"UID: %@", test.UID]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"criteria: %@", test.criteria]]).to.beTruthy();
		});
		
	});
	
	describe(@"-debugDescription", ^{
		
		it(@"returns an NSString", ^{
			TRSCriteria *testCrit = [[TRSCriteria alloc] initWithMark:@4 type:kTRSTotal];
			TRSProductReview *test = [[TRSProductReview alloc] initWithCreationDate:[NSDate date]
																			comment:@"comment"
																			   mark:@4 UID:@"blablubb"
																		   criteria:@[testCrit]];
			NSString *desc = [test description];
			expect(desc).to.beKindOf([NSString class]);
			expect([desc containsString:[NSString stringWithFormat:@"creationDate: %@", test.creationDate]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"comment: %@", test.comment]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"mark: %@", test.mark]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"UID: %@", test.UID]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"criteria: <NSArray: %p>", test.criteria]]).to.beTruthy();
		});
		
	});

});

SpecEnd
