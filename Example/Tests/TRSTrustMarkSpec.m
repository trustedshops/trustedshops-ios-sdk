//
//  TRSTrustMarkSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 07/04/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "TRSTrustMark.h"
#import <Specta/Specta.h>

SpecBegin(TRSTrustMark)

describe(@"TRSTrustMark", ^{
	__block TRSTrustMark *testMark;
	__block NSDictionary *testData;
	beforeAll(^{
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
		NSData *data = [NSData dataWithContentsOfFile:path];
		testData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"response"][@"data"][@"shop"][@"trustMark"];
	});
	
	afterAll(^{
		testData = nil;
	});
	
	describe(@"-init", ^{
		it(@"should return a validtrustmark with INVALID status and other properties as nil", ^{
			testMark = [[TRSTrustMark alloc] init];
			expect(testMark).to.beKindOf([TRSTrustMark class]);
			expect(testMark.status).to.equal(@"INVALID");
			expect(testMark.validFrom).to.beNil();
			expect(testMark.validTo).to.beNil;
			testMark = nil;
		});
	});
	
	describe(@"initWithDictionary:", ^{
		beforeEach(^{
			testMark = [[TRSTrustMark alloc] initWithDictionary:testData];
		});
		afterEach(^{
			testMark = nil;
		});
		
		it(@"should return a valid TRSTrustMark", ^{
			expect(testMark).toNot.beNil();
			expect(testMark).to.beKindOf([TRSTrustMark class]);
			expect(testMark.status).toNot.beNil();
			expect(testMark.validFrom).toNot.beNil();
			expect(testMark.validTo).toNot.beNil;
		});
		
		it(@"should have the correct values set", ^{
			expect(testMark.status).to.equal(testData[@"status"]);
			NSDateFormatter *dateFormatter = [NSDateFormatter new];
			dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
			NSDate *fromDate = [dateFormatter dateFromString:testData[@"validFrom"]];
			NSDate *toDate= [dateFormatter dateFromString:testData[@"validTo"]];
			expect(testMark.validFrom).to.equal(fromDate);
			expect(testMark.validTo).to.equal(toDate);
		});
	});
});

SpecEnd
