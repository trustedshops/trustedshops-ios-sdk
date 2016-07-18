//
//  TRSCriteriaSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 18/07/16.
//

#import "TRSCriteria.h"
#import <Specta/Specta.h>

SpecBegin(TRSCriteria)

describe(@"TRSCriteria", ^{
	
	describe(@"-initWithMark:type", ^{
		
		it(@"does not allow marks above 5", ^{
			TRSCriteria *test = [[TRSCriteria alloc] initWithMark:@5.1 type:kTRSTotal];
			expect([test.mark floatValue]).to.beLessThanOrEqualTo(5.0f);
		});
		
		it(@"does not allow marks below 1", ^{
			TRSCriteria *test = [[TRSCriteria alloc] initWithMark:@0.1 type:kTRSTotal];
			expect([test.mark floatValue]).to.beGreaterThanOrEqualTo(1.0f);
		});
		
		it(@"returns a TRSCriteria object", ^{
			TRSCriteria *test = [[TRSCriteria alloc] initWithMark:@4 type:kTRSTotal];
			expect(test).toNot.beNil();
			expect(test).to.beKindOf([TRSCriteria class]);
		});
		
	});
	
	describe(@"-init", ^{
		
		it(@"returns a basic criteria object", ^{
			
			TRSCriteria *test = [[TRSCriteria alloc] init];
			expect(test.mark).to.beKindOf([NSNumber class]);
			expect([test.mark floatValue]).to.equal(1.0f);
			expect(test).to.beKindOf([TRSCriteria class]);
			expect(test.type).to.equal(kTRSTotal);
			
		});
		
	});
	
	describe(@"-debugDescription", ^{
		
		it(@"returns an NSString", ^{
			TRSCriteria *test = [[TRSCriteria alloc] initWithMark:@5 type:kTRSTotal];
			NSString *desc = [test debugDescription];
			expect(desc).to.beKindOf([NSString class]);
			expect([desc containsString:[NSString stringWithFormat:@"Mark: %@", test.mark]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"Type: %ld", (unsigned long) test.type]]).to.beTruthy();
		});
		
	});
	
	describe(@"-description", ^{
		
		it(@"returns an NSString", ^{
			TRSCriteria *test = [[TRSCriteria alloc] initWithMark:@5 type:kTRSTotal];
			NSString *desc = [test description];
			expect(desc).to.beKindOf([NSString class]);
			expect([desc containsString:[NSString stringWithFormat:@"Mark: %@", test.mark]]).to.beTruthy();
			expect([desc containsString:[NSString stringWithFormat:@"Type: %ld", (unsigned long) test.type]]).to.beTruthy();
		});
		
	});
	
});

SpecEnd
