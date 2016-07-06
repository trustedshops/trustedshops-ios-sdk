//
//  TRSPrivateBasicDataViewSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 06/07/16.
//

#import "TRSPrivateBasicDataView.h"
#import "TRSPrivateBasicDataView+Private.h"
//#import "TRSNetworkAgent.h"
#import "TRSErrors.h"
#import "NSURL+TRSURLExtensions.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>

SpecBegin(TRSPrivateBasicDataView)

context(@"initialization", ^{
	
	// note that there is an NSLog() in this class, so that will clutter the output of the tests a bit.
	describe(@"-initWithFrame:trustedShopsID:apiToken:", ^{
		
		it(@"sets the properties correctly", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			expect(testView.tsID).to.equal(@"anID");
			expect(testView.apiToken).to.equal(@"aToken");
			expect(testView.frame).to.equal(frame);
		});
		
		it(@"calls finishInit", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			id mockView = OCMPartialMock(testView);
			OCMExpect([mockView finishInit]);
			// must re-init, otherwise we couldn't have prepared the mock
			id notneeded = [mockView initWithFrame:frame trustedShopsID:@"anID" apiToken:@"aToken"];
			expect(notneeded).to.beKindOf([TRSPrivateBasicDataView class]);
			OCMVerifyAll(mockView);
		});
		
	});
	
	describe(@"-initWithFrame:", ^{
		
		it(@"returns a view with tsID and apiToken of nil", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame];
			expect(testView.tsID).to.beNil();
			expect(testView.apiToken).to.beNil();
			expect(testView.frame).to.equal(frame);
		});
		
	});
	
	describe(@"-encodeWithCoder: and -initWithCoder:", ^{
		
		it(@"properly encodes all properties", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *view = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																			trustedShopsID:@"anID"
																				  apiToken:@"aToken"];
			
			view.debugMode = YES;
			NSMutableData *storage = [NSMutableData new];
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:storage];
			[view encodeWithCoder:archiver];
			[archiver finishEncoding];
			view = nil;
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:storage];
			TRSPrivateBasicDataView *unpacked = [[TRSPrivateBasicDataView alloc] initWithCoder:unarchiver];
			
			expect(unpacked.tsID).to.equal(@"anID");
			expect(unpacked.apiToken).to.equal(@"aToken");
			expect(unpacked.debugMode).to.beTruthy();;
		});

	});
	
});

describe(@"-loadViewDataFromBackendWithSuccessBlock:failureBlock:", ^{
	
	context(@"with valid credential data", ^{
		
		it(@"calls the relevant setup method rumps that are to be filled in subclasses", ^{
			
			// mock/stub the methods responsible for fetching data!
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			id mockView = OCMPartialMock(testView);
			OCMStub([mockView performNetworkRequestWithSuccessBlock:[OCMArg invokeBlock] failureBlock:[OCMArg any]]);
			OCMExpect([testView setupData:[OCMArg any]]);
			OCMExpect([testView finishLoading]);

			waitUntil(^(DoneCallback done) {
				[mockView loadViewDataFromBackendWithSuccessBlock:^{
					done();
				} failureBlock:nil];
			});
			// see class for this: we have an artificial delay, so we need to wait before checking for changes!
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				OCMVerify([testView finishLoading]);
				OCMVerify([testView setupData:[OCMArg any]]);
			});
			
			// ... somehow I still can't believe this works...
			
		});
		
	});
	
	context(@"error handling", ^{
		
		it(@"calls its failure block with an appropriate error if setupData returns NO", ^{
			// mock/stub the methods responsible for fetching data!
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			id mockView = OCMPartialMock(testView);
			OCMStub([mockView performNetworkRequestWithSuccessBlock:[OCMArg invokeBlock] failureBlock:[OCMArg any]]);
			OCMStub([mockView setupData:[OCMArg any]]).andReturn(NO);
			OCMExpect([testView finishLoading]);
			
			waitUntil(^(DoneCallback done) {
				[mockView loadViewDataFromBackendWithSuccessBlock:nil
													 failureBlock:^(NSError *error) {
														 expect(error.code).to.equal(TRSErrorDomainInvalidData);
														 done();
													 }];
			});
			// see class for this: we have an artificial delay, so we need to wait before checking for changes!
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				OCMVerify([testView finishLoading]);
			});
		});
		
	});
	
});

context(@"helper methods", ^{
	
	
	
});

SpecEnd
