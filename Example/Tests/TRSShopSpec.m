//
//  TRSShopSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 21/03/16.
//

#import "TRSShop.h"
#import "TRSTrustMark.h"
#import <Specta/Specta.h>

SpecBegin(TRSShop)

describe(@"TRSShop", ^{
	
	__block TRSShop *testShop;
	__block NSDictionary *testData;
	beforeAll(^{
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
		NSData *data = [NSData dataWithContentsOfFile:path];
		testData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"response"][@"data"][@"shop"];
		testShop = [[TRSShop alloc] initWithDictionary:testData];
	});
	
	afterAll(^{
		testShop = nil;
		testData = nil;
	});
	
	describe(@"init", ^{
		
		it(@"returns nil", ^{
			expect([[TRSShop alloc] init]).to.beNil();
		});
		
	});
	
	describe(@"-initWithDictionary:", ^{
		
		context(@"with valid data", ^{
			
			it(@"doesn't return nil", ^{
				expect(testShop).toNot.beNil();
			});
			
			it(@"returns a TRSShop instance", ^{
				expect(testShop).to.beKindOf([TRSShop class]);
			});
		});
		
		context(@"with invalid data", ^{
			
			it(@"returns nil for an invalid dictionary", ^{
				TRSShop *willBeNil = [[TRSShop alloc] initWithDictionary:@{@"notakey" : @"notavalue"}];
				expect(willBeNil).to.beNil();
			});
			
			it(@"returns nil for a nil as dictionary", ^{
				expect([[TRSShop alloc] initWithDictionary:nil]).to.beNil();
			});
			
			it(@"returns nil for a dictionary with bad trustmark info", ^{
				NSMutableDictionary *mutTestData = [testData mutableCopy];
				[mutTestData setObject:@"notadictionary" forKey:@"trustMark"];
				expect([[TRSShop alloc] initWithDictionary:mutTestData]).to.beNil();
			});
		});
	});
	
	it(@"has the correct TSID", ^{
		expect(testShop.tsId).to.equal(testData[@"tsId"]);
	});
	
	it(@"has the correct url", ^{
		expect(testShop.url).to.equal(testData[@"url"]);
	});
	
	it(@"has the correct name", ^{
		expect(testShop.name).to.equal(testData[@"name"]);
	});
	
	it(@"has the correct languageISO2", ^{
		expect(testShop.languageISO2).to.equal(testData[@"languageISO2"]);
	});
	
	it(@"has the correct targetMarketISO3", ^{
		expect(testShop.targetMarketISO3).to.equal(testData[@"targetMarketISO3"]);
	});
	
	it(@"has a TRSTrustMark object property", ^{
		expect(testShop.trustMark).to.beKindOf([TRSTrustMark class]);
	});
	
});

SpecEnd
