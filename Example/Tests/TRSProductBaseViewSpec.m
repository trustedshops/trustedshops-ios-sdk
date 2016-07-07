//
//  TRSProductBaseViewSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 06/07/16.
//

#import "TRSProductBaseView.h"
#import "TRSProductBaseView+Private.h"
#import "TRSPrivateBasicDataView+Private.h"
#import "TRSNetworkAgent+ProductGrade.h"
#import "TRSErrors.h"
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>

SpecBegin(TRSProductBaseView)

context(@"initialization", ^{
	
	// note that there is an NSLog() in this class, so that will clutter the output of the tests a bit.
	describe(@"-initWithFrame:trustedShopsID:apiToken:SKU:", ^{
		
		it(@"sets the properties correctly", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *testView = [[TRSProductBaseView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			expect(testView.tsID).to.equal(@"anID");
			expect(testView.apiToken).to.equal(@"aToken");
			expect(testView.SKU).to.equal(@"20610");
			expect(testView.frame).to.equal(frame);
		});
		
		it(@"calls finishInit", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *testView = [[TRSProductBaseView alloc] initWithFrame:frame
																	  trustedShopsID:@"anID"
																			apiToken:@"aToken"
																				 SKU:@"20610"];
			id mockView = OCMPartialMock(testView);
			OCMExpect([mockView finishInit]);
			// must re-init, otherwise we couldn't have prepared the mock
			id notneeded = [mockView initWithFrame:frame trustedShopsID:@"anID" apiToken:@"aToken" SKU:@"20610"];
			expect(notneeded).to.beKindOf([TRSPrivateBasicDataView class]);
			OCMVerifyAll(mockView);
		});
		
	});
	
	describe(@"-initWithFrame:trustedShopsID:apiToken:", ^{
		
		it(@"returns a view with an SKU of nil", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *testView = [[TRSProductBaseView alloc] initWithFrame:frame trustedShopsID:@"foo" apiToken:@"bar"];
			expect(testView.SKU).to.beNil();
		});
		
	});
	
	describe(@"-encodeWithCoder: and -initWithCoder:", ^{
		
		it(@"properly encodes all properties", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *view = [[TRSProductBaseView alloc] initWithFrame:frame
																  trustedShopsID:@"anID"
																		apiToken:@"aToken"
																			 SKU:@"20610"];
			
			view.debugMode = YES;
			NSMutableData *storage = [NSMutableData new];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:storage];
			[view encodeWithCoder:archiver];
			[archiver finishEncoding];
			view = nil;
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:storage];
			TRSProductBaseView *unpacked = [[TRSProductBaseView alloc] initWithCoder:unarchiver];
			
			expect(unpacked.tsID).to.equal(@"anID");
			expect(unpacked.apiToken).to.equal(@"aToken");
			expect(unpacked.SKU).to.equal(@"20610");
			expect(unpacked.debugMode).to.beTruthy();
		});
		
	});
	
});

context(@"helper methods", ^{
	
	describe(@"-performNetworkRequestWithSuccessBlock:failureBlock:", ^{
		
		it(@"calls getProductGradeForTrustedShopsID:apiToken:SKU:success:failure: with the given blocks", ^{
			// prepare the mock objects to get mocked agent
			TRSNetworkAgent *agent = [[TRSNetworkAgent alloc] init];
			id agentMock = OCMPartialMock(agent);
			id agentClassMock = OCMClassMock([TRSNetworkAgent class]);
			OCMStub([agentClassMock sharedAgent]).andReturn(agentMock);
			
			// prepare variables (will ensure these are used in call
			NSString *anID = @"anID";
			NSString *aToken = @"aToken";
			NSString *anSKU = @"anSKU";
			void (^aSuccessBlock)(id resultData) = ^(id resultData) {
				// nothing to do here, just need the pointer
			};
			void (^aFailureBlock)(NSError *error) = ^(NSError *error) {
				// nothing to do here, just need the pointer
			};
			
			// stub and expect the method (stub, beause I don't want any real network calls being mde)
			OCMStub([agentMock getProductGradeForTrustedShopsID:anID
													   apiToken:aToken
															SKU:anSKU
														success:aSuccessBlock
														failure:aFailureBlock]);
			OCMExpect([agentMock getProductGradeForTrustedShopsID:anID
														 apiToken:aToken
															  SKU:anSKU
														  success:aSuccessBlock
														  failure:aFailureBlock]);
			
			// finally test the method...
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *view = [[TRSProductBaseView alloc] initWithFrame:frame
																  trustedShopsID:anID
																		apiToken:aToken
																			 SKU:anSKU];
			[view performNetworkRequestWithSuccessBlock:aSuccessBlock failureBlock:aFailureBlock];
			OCMVerify([agentMock getProductGradeForTrustedShopsID:anID
														 apiToken:aToken
															  SKU:anSKU
														  success:aSuccessBlock
														  failure:aFailureBlock]);
		});
		
	});
	
	describe(@"-setupData:", ^{
		
		it(@"sets up internal data and returns YES for good input", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *view = [[TRSProductBaseView alloc] initWithFrame:frame
																  trustedShopsID:@"anID"
																		apiToken:@"aToken"
																			 SKU:@"20610"];
			NSDictionary *theData = @{@"sku": @"20610", // the method checks for this
									  @"name": @"someName",
									  @"uuid": @"someUUID",
									  @"totalReviewCount": @1344,
									  @"overallMark": @4.86,
									  @"overallMarkDescription": @"EXCELLENT"};
			expect([view setupData:theData]).to.beTruthy();
			expect(view.name).to.equal(@"someName");
			expect(view.uuid).to.equal(@"someUUID");
			expect(view.totalReviewCount).to.equal(@1344);
			expect(view.overallMark).to.equal(@4.86);
			expect(view.overallMarkDescription).to.equal(@"EXCELLENT");
		});
		
		it(@"returns NO for mismatching SKU and doesn't set internal data", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *view = [[TRSProductBaseView alloc] initWithFrame:frame
																  trustedShopsID:@"anID"
																		apiToken:@"aToken"
																			 SKU:@"20610"];
			NSDictionary *theData = @{@"sku": @"DIFFERENT", // the method checks for this
									  @"name": @"someName",
									  @"uuid": @"someUUID",
									  @"totalReviewCount": @1344,
									  @"overallMark": @4.86,
									  @"overallMarkDescription": @"EXCELLENT"};
			expect([view setupData:theData]).to.beFalsy();
			expect(view.name).to.beNil();
			expect(view.uuid).to.beNil();
			expect(view.totalReviewCount).to.beNil();
			expect(view.overallMark).to.beNil();
			expect(view.overallMarkDescription).to.beNil();
		});
		
	});
	
	describe(@"-finishLoading", ^{
		
		// atm the method doesn't really do anything besides informing via NSLog that it should be overridden,
		// so I simply ensure it doesn't crash here
		it(@"doesn't raise an exception", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSProductBaseView *view = [[TRSProductBaseView alloc] initWithFrame:frame
																  trustedShopsID:@"anID"
																		apiToken:@"aToken"
																			 SKU:@"20610"];
			XCTAssertNoThrow([view finishLoading], @"-finishLoading did throw an error!");
		});
		
	});
	
});


SpecEnd
