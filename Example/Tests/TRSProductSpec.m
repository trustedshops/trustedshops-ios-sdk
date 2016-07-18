//
//  TRSProductSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 29/04/16.
//

#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import "TRSProduct.h"
#import "TRSNetworkAgent+ProductGrade.h"

SpecBegin(TRSProduct)

describe(@"TRSProduct", ^{
	
	describe(@"-initWithUrl:name:SKU:", ^{
		
		context(@"with valid values", ^{
			
			__block TRSProduct *testProduct;
			beforeAll(^{
				testProduct = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.google.de"]
														 name:@"testname" SKU:@"1234567890AB"];
			});
			afterAll(^{
				testProduct = nil;
			});
			
			it(@"returns not nil", ^{
				expect(testProduct).toNot.beNil();
			});
			
			it(@"returns an object of type TRSProduct", ^{
				expect(testProduct).to.beKindOf([TRSProduct class]);
			});
			
			it(@"has the correct required properties", ^{
				expect([testProduct.url absoluteString]).to.equal(@"https://www.google.de");
				expect(testProduct.name).to.equal(@"testname");
				expect(testProduct.SKU).to.equal(@"1234567890AB");
			});
			
		});
		
		context(@"with an empty name string", ^{
			it(@"returns nil", ^{
				TRSProduct *failedProduct = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.google.de"]
																	   name:@"" SKU:@"1234567890AB"];
				expect(failedProduct).to.beNil();
			});
		});
		
		context(@"with an empty SKU string", ^{
			it(@"returns nil", ^{
				TRSProduct *failedProduct = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.google.de"]
																	   name:@"testname" SKU:@""];
				expect(failedProduct).to.beNil();
			});
		});
		
	});
	
	describe(@"-loadReviewsFromBackendWithTrustedShopsID:apiToken:successBlock:failureBlock:", ^{
		
		__block id agent;
		__block id mockAgent;
		__block TRSProduct *loadTestProduct;
		beforeEach(^{
			// stub the shared agent method to return a partial mock...
			TRSNetworkAgent *realAgent = [[TRSNetworkAgent alloc] init];
			realAgent.debugMode = YES;
			agent = OCMPartialMock(realAgent);
			mockAgent = OCMClassMock([TRSNetworkAgent class]);
			OCMStub([mockAgent sharedAgent]).andReturn(agent);
			
			loadTestProduct = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.google.de"]
														 name:@"testname"
														  SKU:@"20610"];
			loadTestProduct.debugMode = YES;
		});
		
		it(@"calls getProductReviewsForTrustedShopsID:apiToken:SKU:success:failure:", ^{
			
			OCMStub([agent getProductReviewsForTrustedShopsID:[OCMArg any]
													 apiToken:[OCMArg any]
														  SKU:[OCMArg any]
													  success:[OCMArg any]
													  failure:[OCMArg any]]);
			OCMExpect([agent getProductReviewsForTrustedShopsID:@"aTSID"
													   apiToken:@"aToken"
															SKU:@"20610"
														success:[OCMArg any]
														failure:[OCMArg any]]);
			[loadTestProduct loadReviewsFromBackendWithTrustedShopsID:@"aTSID"
															 apiToken:@"aToken"
														 successBlock:nil
														 failureBlock:nil];
			OCMVerify([agent getProductReviewsForTrustedShopsID:@"aTSID"
													   apiToken:@"aToken"
															SKU:@"20610"
														success:[OCMArg any]
														failure:[OCMArg any]]);
		});
		
		it(@"gets reviews for a success", ^{
			
			NSArray *fakeReviewArray = @[@"not real reviews", @"nope, not at all"];
			OCMStub([agent getProductReviewsForTrustedShopsID:[OCMArg any]
													 apiToken:[OCMArg any]
														  SKU:[OCMArg any]
													  success:([OCMArg invokeBlockWithArgs:fakeReviewArray, nil])
													  failure:[OCMArg any]]);
			
			[loadTestProduct loadReviewsFromBackendWithTrustedShopsID:@"aTSID"
															 apiToken:@"aToken"
														 successBlock:^{
															 expect(loadTestProduct.reviews).toNot.beNil();
														 }
														 failureBlock:nil];
		});
		
	});
	
});


SpecEnd
