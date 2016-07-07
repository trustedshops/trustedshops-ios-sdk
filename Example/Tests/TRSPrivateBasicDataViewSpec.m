//
//  TRSPrivateBasicDataViewSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 06/07/16.
//

#import "TRSPrivateBasicDataView.h"
#import "TRSPrivateBasicDataView+Private.h"
#import "TRSErrors.h"
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
			// this is a weird issie: I have to stub and forward for the expecation to properly work, otherwise
			// the code coverage doesn't realize the method has been called (since it was called on the mock I guess)
			OCMStub([mockView setupData:[OCMArg any]]).andForwardToRealObject();
			OCMStub([mockView finishLoading]).andForwardToRealObject();
			OCMExpect([mockView setupData:[OCMArg any]]);
			OCMExpect([mockView finishLoading]);

			waitUntil(^(DoneCallback done) {
				[mockView loadViewDataFromBackendWithSuccessBlock:^{
					done();
				} failureBlock:nil];
			});
			// see class for this: we have an artificial delay, so we need to wait before checking for changes!
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				OCMVerify([mockView finishLoading]);
				OCMVerify([mockView setupData:[OCMArg any]]);
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
			
			waitUntil(^(DoneCallback done) {
				[mockView loadViewDataFromBackendWithSuccessBlock:nil
													 failureBlock:^(NSError *error) {
														 expect(error.code).to.equal(TRSErrorDomainInvalidData);
														 done();
													 }];
			});
		});
		
		it(@"calls its failure block with an appropriate error if performNetworkRequest... demands it", ^{
			// mock/stub the methods responsible for fetching data!
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			id mockView = OCMPartialMock(testView);
			NSError *error = [NSError errorWithDomain:TRSErrorDomain
												 code:TRSErrorDomainUnknownError // TRSErrorDomainInvalidTSID below
											 userInfo:nil];
			OCMStub([mockView performNetworkRequestWithSuccessBlock:[OCMArg any] failureBlock:([OCMArg invokeBlockWithArgs:error, nil])]);
			
			waitUntil(^(DoneCallback done) {
				[mockView loadViewDataFromBackendWithSuccessBlock:nil
													 failureBlock:^(NSError *error) {
														 expect(error.code).to.equal(TRSErrorDomainUnknownError);
														 done();
													 }];
			});
		});
		
		it(@"also works for unknown errors from performNetworkRequest...", ^{
			// mock/stub the methods responsible for fetching data!
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			id mockView = OCMPartialMock(testView);
			NSError *error = [NSError errorWithDomain:TRSErrorDomain
												 code:TRSErrorDomainInvalidTSID
											 userInfo:nil];
			OCMStub([mockView performNetworkRequestWithSuccessBlock:[OCMArg any] failureBlock:([OCMArg invokeBlockWithArgs:error, nil])]);
			OCMStub([mockView logStringForError:error]).andForwardToRealObject(); // forward for code coverage
			OCMExpect([mockView logStringForError:error]);

			waitUntil(^(DoneCallback done) {
				[mockView loadViewDataFromBackendWithSuccessBlock:nil
													 failureBlock:^(NSError *error) {
														 expect(error.code).to.equal(TRSErrorDomainInvalidTSID);
														 done();
													 }];
				
			});
			// see class for this: we have an artificial delay, so we need to wait before checking for changes!
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				OCMVerify([mockView logStringForError:error]);
			});
		});
	});
	
});

context(@"helper methods", ^{
	
	describe(@"-performNetworkRequestWithSuccessBlock:failureBlock:", ^{
		
		it(@"raises an exception", ^{
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			expect(^{[testView performNetworkRequestWithSuccessBlock:nil failureBlock:nil];}).to.raiseAny();
		});
		
	});
	
	describe(@"-logStringForError:", ^{
		
		it(@"returns an NSString for all relevant error codes", ^{
			
			NSError *error1 = [NSError errorWithDomain:TRSErrorDomain code:TRSErrorDomainInvalidAPIToken userInfo:nil];
			NSError *error2 = [NSError errorWithDomain:TRSErrorDomain code:TRSErrorDomainInvalidTSID userInfo:nil];
			NSError *error3 = [NSError errorWithDomain:TRSErrorDomain code:TRSErrorDomainTSIDNotFound userInfo:nil];
			NSError *error4 = [NSError errorWithDomain:TRSErrorDomain code:TRSErrorDomainInvalidData userInfo:nil];
			NSError *error5 = [NSError errorWithDomain:TRSErrorDomain code:TRSErrorDomainMissingTSIDOrAPIToken userInfo:nil];
			
			CGRect frame = CGRectMake(0.0, 0.0, 200.0, 40.0);
			TRSPrivateBasicDataView *testView = [[TRSPrivateBasicDataView alloc] initWithFrame:frame
																				trustedShopsID:@"anID"
																					  apiToken:@"aToken"];
			
			expect([testView logStringForError:error1]).toNot.beNil();
			expect([testView logStringForError:error1]).to.beKindOf([NSString class]);
			expect([testView logStringForError:error2]).toNot.beNil();
			expect([testView logStringForError:error2]).to.beKindOf([NSString class]);
			expect([testView logStringForError:error3]).toNot.beNil();
			expect([testView logStringForError:error3]).to.beKindOf([NSString class]);
			expect([testView logStringForError:error4]).toNot.beNil();
			expect([testView logStringForError:error4]).to.beKindOf([NSString class]);
			expect([testView logStringForError:error5]).toNot.beNil();
			expect([testView logStringForError:error5]).to.beKindOf([NSString class]);
		});
		
	});
	
});

SpecEnd
