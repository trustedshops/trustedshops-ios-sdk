//
//  TRSTrustbadgeViewSpec.m
//  Trustbadge
//
//  Taken up by Gero Herkenrath on 22/03/16.
//

#import "TRSTrustbadgeView.h"
#import "TRSTrustbadge.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "NSURL+TRSURLExtensions.h"
#import "TRSErrors.h"
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <Specta/Specta.h>

@interface TRSTrustbadgeView (PrivateTests)

@property (nonatomic, copy, readwrite) NSString *trustedShopsID;
@property (nonatomic, copy, readwrite) NSString *apiToken;
@property (nonatomic, strong) UILabel *offlineMarker;
@property (nonatomic, strong) TRSTrustbadge *trustbadge;
@property (nonatomic, strong) UIImageView *sealImageView;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (instancetype)finishInit:(NSString *)trustedShopsID apiToken:(NSString *)apiToken;
- (void)displaySealAsOffline:(BOOL)offline afterDelay:(NSTimeInterval)seconds;

@end

// Note: For now the debugMode property is set to YES for all initialized TRSTrustbadgeView objects.
// This should not affect tests (as in "not testing non-debug mode"), since all it does is ensure
// the agent it uses to make HTTPRequests uses the QA environment API (a different URL) and not the production
// one. The code that is tested is completely identical, however, so everything IS tested.
// The HTTP stubs are set similarly. I do so in case I mess up something with the stubs in the future, so I at least
// won't mess with the PROD environment while testing.

SpecBegin(TRSTrustbadgeView)

describe(@"TRSTrustbadgeView", ^{

    __block TRSNetworkAgent *agent;
    __block id networkMock;
    beforeAll(^{
        agent = [[TRSNetworkAgent alloc] init];
		agent.debugMode = YES;
        networkMock = OCMClassMock([TRSNetworkAgent class]);
        OCMStub([networkMock sharedAgent]).andReturn(agent);
    });

    afterAll(^{
        agent = nil;
        networkMock = nil;
    });
	
    describe(@"-initWithFrame:trustedShopsID:apiToken", ^{
		
		sharedExamplesFor(@"an initialized TRSTrustbadgeView", ^(NSDictionary *data) {
			it(@"returns a `TRSTrustbadgeView` object", ^{
				expect(data[@"trustbadgeView"]).to.beKindOf([TRSTrustbadgeView class]);
			});
			it(@"has a default color", ^{
				expect([data[@"trustbadgeView"] customColor]).toNot.beNil();
			});
		});
		
		sharedExamplesFor(@"a failing load", ^(NSDictionary *data) {
			
			it(@"executes the failure block", ^{
				waitUntil(^(DoneCallback done) {
					[data[@"trustbadgeView"] loadTrustbadgeWithSuccessBlock:nil
															   failureBlock:^(NSError *error) {
																   done();
															   }];
				});
			});
			
			it(@"passes a custom trustbadge error domain", ^{
				waitUntil(^(DoneCallback done) {
					[data[@"trustbadgeView"] loadTrustbadgeWithSuccessBlock:nil
															   failureBlock:^(NSError *error) {
																   expect(error.domain).to.equal(TRSErrorDomain);
																   done();
															   }];
				});
			});
		});

        context(@"with a valid Trusted Shops ID", ^{

			__block TRSTrustbadgeView *view;
            beforeEach(^{
                NSString *trustedShopsID = @"999888777666555444333222111000999";
				NSString *thisIsAFakeToken = @"24124nw2rwoedsfweslefq2121wsdaaf326480349nsdlk7883nw123nvsle5d3";

                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					NSURL *usedInAgent = [NSURL trustMarkAPIURLForTSID:trustedShopsID debug:YES];
					return [request.URL isEqual:usedInAgent];
                } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                    NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    return [OHHTTPStubsResponse responseWithData:data
                                                      statusCode:200
                                                         headers:nil];
                }];
				
				CGRect aRect = CGRectMake(0.0, 0.0, 50.0, 50.0);
				view = [[TRSTrustbadgeView alloc] initWithFrame:aRect trustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
				view.debugMode = YES;
            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
                view = nil;
            });
			
			it(@"has a trustedShopsID", ^{
				expect([view trustedShopsID]).toNot.beNil();
			});
			
			it(@"has a apiToken", ^{
				expect([view apiToken]).toNot.beNil();
			});
			
            it(@"returns the same ID", ^{
                expect(view.trustedShopsID).to.equal(@"999888777666555444333222111000999");
            });
			
			it(@"returns the same api token", ^{
				expect(view.apiToken).to.equal(@"24124nw2rwoedsfweslefq2121wsdaaf326480349nsdlk7883nw123nvsle5d3");
			});
			
			itShouldBehaveLike(@"an initialized TRSTrustbadgeView", ^{
				return @{@"trustbadgeView" : view};
			});
			
			describe(@"-loadTrustbadgeWithSuccessBlock:failureBlock:", ^{
				
				it(@"executes the success block", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:^{
							done();
						}
												failureBlock:nil];
					});
				});
			});
			
			context(@"data got corrupted", ^{
				it(@"calls the failure block with invalid data error", ^{
					// first, we have to change the network stub
					[OHHTTPStubs removeAllStubs];
					[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) { // ID copied from above...
						NSURL *usedInAgent = [NSURL trustMarkAPIURLForTSID:@"999888777666555444333222111000999" debug:YES];
						return [request.URL isEqual:usedInAgent];
					} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
						NSError *networkError = [NSError errorWithDomain:TRSErrorDomain	code:TRSErrorDomainInvalidData userInfo:nil];
						return [OHHTTPStubsResponse responseWithError:networkError];
					}];
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithFailureBlock:^(NSError *error) {
							expect(error.code).to.equal(TRSErrorDomainInvalidData); // kinda pointless, I defined it so...
							done();
						}];
					});
				});
			});
			
			context(@"an error from a different domain happened", ^{
				it(@"just calls the error block without changing the error code", ^{
					// first, we have to change the network stub
					[OHHTTPStubs removeAllStubs];
					[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) { // ID copied from above...
						NSURL *usedInAgent = [NSURL trustMarkAPIURLForTSID:@"999888777666555444333222111000999" debug:YES];
						return [request.URL isEqual:usedInAgent];
					} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
						NSError *networkError = [NSError errorWithDomain:@"whatever" code:666 userInfo:nil];
						return [OHHTTPStubsResponse responseWithError:networkError];
					}];
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithFailureBlock:^(NSError *error) {
							expect(error.code).to.equal(666); // kinda pointless, I defined it so...
							done();
						}];
					});
				});
			});

        });

        context(@"with a nil-object", ^{

            __block TRSTrustbadgeView *view;
            beforeEach(^{
				CGRect aRect = CGRectMake(0.0, 0.0, 50.0, 50.0);
				view = [[TRSTrustbadgeView alloc] initWithFrame:aRect trustedShopsID:nil apiToken:nil];
				view.debugMode = YES;
            });

            afterEach(^{
                view = nil;
            });
			
			itShouldBehaveLike(@"an initialized TRSTrustbadgeView", ^{
				return @{@"trustbadgeView" : view};
			});

			it(@"returns nil as the ID", ^{
				expect(view.trustedShopsID).to.beNil();
			});

			it(@"returns nil as the api token", ^{
				expect(view.apiToken).to.beNil();
			});

			describe(@"-loadTrustbadgeWithSuccessBlock:failureBlock:", ^{
				
				itShouldBehaveLike(@"a failing load", ^{
					return @{@"trustbadgeView" : view};
				});
				
				it(@"returns a TRSErrorDomainMissingTSIDOrAPIToken error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainMissingTSIDOrAPIToken);
													done();
												}];
					});
				});
			});
        });

        context(@"with an unknown Trusted Shops ID", ^{
			
			__block TRSTrustbadgeView *view;
			beforeEach(^{
				NSString *trustedShopsID = @"000111222333444555666777888999111";
				NSString *thisIsAFakeToken = @"24124nw2rwoedsfweslefq2121wsdaaf326480349nsdlk7883nw123nvsle5d3";
				
				NSString *file = OHPathForFileInBundle(@"trustbadge-notfound.response", [NSBundle bundleForClass:[self class]]);
				NSData *messageData = [NSData dataWithContentsOfFile:file];
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithHTTPMessageData:messageData];
				
				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					NSURL *usedInAgent = [NSURL trustMarkAPIURLForTSID:trustedShopsID debug:YES];
					return [request.URL isEqual:usedInAgent];
				} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
					return response;
				}];
				
				CGRect aRect = CGRectMake(0.0, 0.0, 50.0, 50.0);
				view = [[TRSTrustbadgeView alloc] initWithFrame:aRect trustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
				view.debugMode = YES;
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
				view = nil;
			});
			
			itShouldBehaveLike(@"an initialized TRSTrustbadgeView", ^{
				return @{@"trustbadgeView" : view};
			});
			
			it(@"returns the same ID", ^{
				expect(view.trustedShopsID).to.equal(@"000111222333444555666777888999111");
			});
			
			it(@"returns the same api token", ^{
				expect(view.apiToken).to.equal(@"24124nw2rwoedsfweslefq2121wsdaaf326480349nsdlk7883nw123nvsle5d3");
			});

			describe(@"-loadTrustbadgeWithSuccessBlock:failureBlock:", ^{
				
				itShouldBehaveLike(@"a failing load", ^{
					return @{@"trustbadgeView" : view};
				});
				
				it(@"returns a TRSErrorDomainTSIDNotFound error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainTSIDNotFound);
													done();
												}];
					});
				});
			});
			
       });

        context(@"with an invalid Trusted Shops ID", ^{
			
			__block TRSTrustbadgeView *view;
			beforeEach(^{
				NSString *trustedShopsID = @"123123123";
				NSString *thisIsAFakeToken = @"24124nw2rwoedsfweslefq2121wsdaaf326480349nsdlk7883nw123nvsle5d3";
				
				NSString *file = OHPathForFileInBundle(@"trustbadge-badrequest.response", [NSBundle bundleForClass:[self class]]);
				NSData *messageData = [NSData dataWithContentsOfFile:file];
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithHTTPMessageData:messageData];

				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					NSURL *usedInAgent = [NSURL trustMarkAPIURLForTSID:trustedShopsID debug:YES];
					return [request.URL isEqual:usedInAgent];
				} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
					return response;
				}];
				
				CGRect aRect = CGRectMake(0.0, 0.0, 50.0, 50.0);
				view = [[TRSTrustbadgeView alloc] initWithFrame:aRect trustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
				view.debugMode = YES;
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
				view = nil;
			});
			
			itShouldBehaveLike(@"an initialized TRSTrustbadgeView", ^{
				return @{@"trustbadgeView" : view};
			});
			
			it(@"returns the same ID", ^{
				expect(view.trustedShopsID).to.equal(@"123123123");
			});
			
			it(@"returns the same api token", ^{
				expect(view.apiToken).to.equal(@"24124nw2rwoedsfweslefq2121wsdaaf326480349nsdlk7883nw123nvsle5d3");
			});
			
			describe(@"-loadTrustbadgeWithSuccessBlock:failureBlock:", ^{
				
				itShouldBehaveLike(@"a failing load", ^{
					return @{@"trustbadgeView" : view};
				});
				
				it(@"returns a TRSErrorDomainInvalidTSID error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainInvalidTSID);
													done();
												}];
					});
				});
			});
		});
		
		context(@"with an invalid apiToken", ^{
			__block TRSTrustbadgeView *view;
			beforeEach(^{
				NSString *trustedShopsID = @"999888777666555444333222111000999";
				NSString *thisIsAFakeToken = @"badToken";
				
				NSString *file = OHPathForFileInBundle(@"trustbadge-badtoken.response", [NSBundle bundleForClass:[self class]]);
				NSData *messageData = [NSData dataWithContentsOfFile:file];
				OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithHTTPMessageData:messageData];

				[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
					NSURL *usedInAgent = [NSURL trustMarkAPIURLForTSID:trustedShopsID debug:YES];
					return [request.URL isEqual:usedInAgent];
				} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
					return response;
				}];
				
				CGRect aRect = CGRectMake(0.0, 0.0, 50.0, 50.0);
				view = [[TRSTrustbadgeView alloc] initWithFrame:aRect trustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
				view.debugMode = YES;
			});
			
			afterEach(^{
				[OHHTTPStubs removeAllStubs];
				view = nil;
			});
			
			itShouldBehaveLike(@"an initialized TRSTrustbadgeView", ^{
				return @{@"trustbadgeView" : view};
			});
			
			it(@"returns the same ID", ^{
				expect(view.trustedShopsID).to.equal(@"999888777666555444333222111000999");
			});
			
			it(@"returns the same api token", ^{
				expect(view.apiToken).to.equal(@"badToken");
			});
			
			describe(@"-loadTrustbadgeWithSuccessBlock:failureBlock:", ^{
				
				itShouldBehaveLike(@"a failing load", ^{
					return @{@"trustbadgeView" : view};
				});
				
				it(@"returns a TRSErrorDomainInvalidAPIToken error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainInvalidAPIToken);
													done();
												}];
					});
				});
			});
		});

    });

	context(@"convenience Initializers", ^{
		__block TRSTrustbadgeView *testView;
		
		describe(@"-initWithTrustedShopsID:apiToken:", ^{
			it(@"creates an object with the default frame", ^{
				testView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"someID" apiToken:@"someToken"];
				testView.debugMode = YES;
				CGRect targetFrame = CGRectMake(0.0, 0.0, 64.0, 64.0);
				expect(CGRectEqualToRect(targetFrame, testView.frame)).to.beTruthy();
				expect(testView.trustedShopsID).to.equal(@"someID");
				expect(testView.apiToken).to.equal(@"someToken");
			});
		});
		
		describe(@"-initWithTrustedShopsID", ^{
			it(@"creates an object with the default frame and no token", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				// Testing deprecated method for completeness, will be removed in future
				testView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"someID"];
#pragma clang diagnostic pop
				testView.debugMode = YES;
				CGRect targetFrame = CGRectMake(0.0, 0.0, 64.0, 64.0);
				expect(CGRectEqualToRect(targetFrame, testView.frame)).to.beTruthy();
				expect(testView.trustedShopsID).to.equal(@"someID");
				expect(testView.apiToken).to.beNil();
			});
		});
		
		describe(@"-initWithFrame:", ^{
			it(@"creates an object with no token and no TS ID", ^{
				testView = [[TRSTrustbadgeView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0)];
				testView.debugMode = YES;
				expect(testView.trustedShopsID).to.beNil();
				expect(testView.apiToken).to.beNil();
			});
		});
		
		describe(@"-init", ^{
			it(@"creates an object with the default frame and no token and no TS ID", ^{
				testView = [[TRSTrustbadgeView alloc] init];
				testView.debugMode = YES;
				CGRect targetFrame = CGRectMake(0.0, 0.0, 64.0, 64.0);
				expect(CGRectEqualToRect(targetFrame, testView.frame)).to.beTruthy();
				expect(testView.trustedShopsID).to.beNil();
				expect(testView.apiToken).to.beNil();
			});
		});
		
		describe(@"-initWithCoder:", ^{ // this is special, as it doesn't call the other designated intializer
			it(@"creates an object with no token and no TS ID", ^{
				NSData *temp = [NSKeyedArchiver archivedDataWithRootObject:[UIView new]];
				NSKeyedUnarchiver *testCoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:temp];
				testView = [[TRSTrustbadgeView alloc] initWithCoder:testCoder];
				testView.debugMode = YES;
				expect(testView.trustedShopsID).to.beNil();
				expect(testView.apiToken).to.beNil();
			});
		});
	});
	
	describe(@"-touchesEnded:withEvent: when not hidden", ^{
		it(@"calls showTrustcard for touch over seal", ^{
			TRSTrustbadgeView *testView = [[TRSTrustbadgeView alloc] init];
			testView.debugMode = YES;
			id mockedTrustbadge = OCMClassMock([TRSTrustbadge class]);
			OCMStub([mockedTrustbadge showTrustcardWithPresentingViewController:nil]);
			id mockedImageView = OCMPartialMock(testView.sealImageView);
			OCMStub([[mockedImageView ignoringNonObjectArgs] pointInside:CGPointMake(0.0, 0.0) withEvent:[OCMArg any]]).andReturn(YES);
			testView.trustbadge = mockedTrustbadge;
			[testView.offlineMarker setHidden:YES];
			UITouch *aTouch = [UITouch new];
			[testView touchesEnded:[NSSet setWithObject:aTouch] withEvent:[UIEvent new]];
			OCMVerify([mockedTrustbadge showTrustcardWithPresentingViewController:nil]);
			OCMVerify([[mockedImageView ignoringNonObjectArgs] pointInside:CGPointMake(0.0, 0.0) withEvent:[OCMArg any]]);
		});
	});
	
	context(@"touch events when hidden", ^{
		// note: the Documentation says we're supposed to implement all touch methods
		// but when we're hidden, we just pass them through, so only test that
		__block id markerPartialMock;
		__block UILabel *originalMarker;
		__block TRSTrustbadgeView *testView;
		beforeEach(^{
			testView = [[TRSTrustbadgeView alloc] init];
			testView.debugMode = YES;
			originalMarker = testView.offlineMarker;
			markerPartialMock = OCMPartialMock(originalMarker);
			testView.offlineMarker = markerPartialMock;
			[testView.offlineMarker setHidden:NO];
			OCMExpect([markerPartialMock isHidden]);
		});
		afterEach(^{
			testView.offlineMarker = originalMarker;
			markerPartialMock = nil;
			testView = nil;
		});
		
		describe(@"-touchesBegan:withEvent:", ^{
			it(@"checks whether the offline marker is hidden", ^{
				[testView touchesBegan:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(markerPartialMock);
			});
		});
		
		describe(@"-touchesMoved:withEvent:", ^{
			it(@"checks whether the offline marker is hidden", ^{
				[testView touchesMoved:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(markerPartialMock);
			});
		});
		
		// this actually does something when seal is not hidden, but we don't test that for now (better for a regression test)
		describe(@"-touchesEnded:withEvent:", ^{
			it(@"checks whether the offline marker is hidden", ^{
				[testView touchesEnded:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(markerPartialMock);
			});
		});
		
		describe(@"-touchesCancelled:withEvent:", ^{
			it(@"checks whether the offline marker is hidden", ^{
				[testView touchesCancelled:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(markerPartialMock);
			});
		});
	});
	
	describe(@"-setCustomColor:", ^{
		__block TRSTrustbadgeView *testView;
		__block UIColor *testColor1;
		__block UIColor *testColor2;
		beforeEach(^{
			testView = [[TRSTrustbadgeView alloc] init];
			testView.debugMode = YES;
			testColor1 = [UIColor blueColor];
			testColor2 = [UIColor redColor];
		});
		afterEach(^{
			testView = nil;
			testColor1 = nil;
			testColor2 = nil;
		});
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		it(@"correctly sets a color", ^{
			[testView setCustomColor:testColor1];
			expect(testView.customColor).to.equal(testColor1);
		});
		
		it(@"correctly changes a set color", ^{
			[testView setCustomColor:testColor1];
			expect(testView.customColor).to.equal(testColor1);
			testView.customColor = testColor2;
			expect(testView.customColor).to.equal(testColor2);
		});
		
		it(@"doesn't change a color if it is set twice", ^{ // erm... I admit it: this is just to raise coverage...
			[testView setCustomColor:testColor1];
			expect(testView.customColor).to.equal(testColor1);
			[testView setCustomColor:testColor1];
			expect(testView.customColor).to.equal(testColor1);
		});
		
		it(@"also sets the color of a trustbadge if it's already loaded", ^{
			id mockedBadge = OCMClassMock([TRSTrustbadge class]);
			testView.trustbadge = mockedBadge;
			OCMExpect([mockedBadge setCustomColor:testColor1]);
			testView.customColor = testColor1;
			OCMVerifyAll(mockedBadge);
		});
#pragma clang diagnostic pop
	});
	
	context(@"private readwrite properties", ^{
		__block TRSTrustbadgeView *testView;
		beforeEach(^{ // not testing for nil values, because meh
			testView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"testID" apiToken:@"testToken"];
			testView.debugMode = YES;
		});
		afterEach(^{
			testView = nil;
		});
		
		describe(@"-trustedShopsID", ^{
			it(@"returns an NSString", ^{
				expect(testView.trustedShopsID).to.beKindOf([NSString class]);
			});
			it(@"returns the id given in init", ^{
				expect(testView.trustedShopsID).to.equal(@"testID");
			});
		});
		describe(@"-apiToken", ^{
			it(@"returns an NSString", ^{
				expect(testView.apiToken).to.beKindOf([NSString class]);
			});
			it(@"returns the id given in init", ^{
				expect(testView.apiToken).to.equal(@"testToken");
			});
		});
		describe(@"-setTrustedShopsID:", ^{
			it(@"changes the ID", ^{
				[testView setTrustedShopsID:@"testIDchanged"];
				expect(testView.trustedShopsID).to.equal(@"testIDchanged");
			});
			it(@"allows nil", ^{
				[testView setTrustedShopsID:nil];
				expect(testView.trustedShopsID).to.beNil();
			});
		});
		describe(@"-setApiToken:", ^{
			it(@"changes the token", ^{
				[testView setApiToken:@"testTokenChanged"];
				expect(testView.apiToken).to.equal(@"testTokenChanged");
			});
			it(@"allows nil", ^{
				[testView setApiToken:nil];
				expect(testView.apiToken).to.beNil();
			});
		});
	});
	
	describe(@"+displaySealAsOffline:afterDelay:", ^{
		it(@"properly sets the seal to offline immediately", ^{
			// the rest of the possible uses is covered more or less in the stuff above
			TRSTrustbadgeView *forDisplaySeal = [TRSTrustbadgeView new];
			[forDisplaySeal displaySealAsOffline:YES afterDelay:0.0];
			expect(forDisplaySeal.hidden).to.beTruthy();
		});
	});
});

SpecEnd
