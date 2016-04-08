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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (instancetype)finishInit:(NSString *)trustedShopsID apiToken:(NSString *)apiToken;

@end

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
						NSError *networkError = [NSError errorWithDomain:TRSErrorDomain	code:TRSErrorDomainTrustbadgeInvalidData userInfo:nil];
						return [OHHTTPStubsResponse responseWithError:networkError];
					}];
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithFailureBlock:^(NSError *error) {
							expect(error.code).to.equal(TRSErrorDomainTrustbadgeInvalidData); // kinda pointless, I defined it so...
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
						NSError *networkError = [NSError errorWithDomain:TRSErrorDomain	code:666 userInfo:nil];
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
				
				it(@"returns a TRSErrorDomainTrustbadgeMissingTSIDOrAPIToken error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainTrustbadgeMissingTSIDOrAPIToken);
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
				
				it(@"returns a TRSErrorDomainTrustbadgeTSIDNotFound error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainTrustbadgeTSIDNotFound);
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
				
				it(@"returns a TRSErrorDomainTrustbadgeInvalidTSID error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainTrustbadgeInvalidTSID);
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
				
				it(@"returns a TRSErrorDomainTrustbadgeInvalidAPIToken error code", ^{
					waitUntil(^(DoneCallback done) {
						[view loadTrustbadgeWithSuccessBlock:nil
												failureBlock:^(NSError *error) {
													expect(error.code).to.equal(TRSErrorDomainTrustbadgeInvalidAPIToken);
													done();
												}];
					});
				});
			});
		});

    });

	context(@"convenience Initializers", ^{
		__block id tbViewClassMock;
		__block TRSTrustbadgeView *testView;
		beforeEach(^{
			tbViewClassMock = OCMClassMock([TRSTrustbadgeView class]);
			CGRect aRect = CGRectMake(0.0, 0.0, 64.0, 64.0);
			OCMStub([tbViewClassMock initWithFrame:aRect trustedShopsID:[OCMArg any] apiToken:[OCMArg any]]);
		});
		afterEach(^{
			[tbViewClassMock stopMocking];
			tbViewClassMock = nil;
			testView = nil;
		});
		
		describe(@"-initWithTrustedShopsID:apiToken:", ^{
			it(@"calls the dedicated initializer", ^{
				testView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"someID" apiToken:@"someToken"];
				OCMVerifyAll(tbViewClassMock);
			});
		});
		
		describe(@"-initWithTrustedShopsID", ^{
			it(@"calls the dedicated initializer", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				// Testing deprecated method for completeness, will be removed in future
				testView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"someID"];
#pragma clang diagnostic pop
				OCMVerifyAll(tbViewClassMock);
			});
		});
		
		describe(@"-initWithFrame:", ^{
			it(@"calls the dedicated initializer", ^{
				testView = [[TRSTrustbadgeView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0)];
				OCMVerifyAll(tbViewClassMock);
			});
		});
		
		describe(@"-init", ^{
			it(@"calls the dedicated initializer", ^{
				testView = [[TRSTrustbadgeView alloc] init];
				OCMVerifyAll(tbViewClassMock);
			});
		});
		
		describe(@"-initWithCoder:", ^{ // this is special, as it doesn't call the dedicated intializer
			it(@"calls UIView's initWithCoder:", ^{
				id superClass = OCMClassMock([TRSTrustbadgeView superclass]);
				OCMStub([superClass initWithCoder:[OCMArg any]]).andReturn(nil);
				NSData *temp = [NSKeyedArchiver archivedDataWithRootObject:[UIView new]];
				NSKeyedUnarchiver *testCoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:temp];
				testView = [[TRSTrustbadgeView alloc] initWithCoder:testCoder];
				OCMVerifyAll(superClass);
			});
		});
	});
	
	describe(@"-touchesEnded:withEvent: when not hidden", ^{
		it(@"calls showTrustcard for touch over seal", ^{
			TRSTrustbadgeView *testView = [[TRSTrustbadgeView alloc] init];
			id mockedTrustbadge = OCMClassMock([TRSTrustbadge class]);
			OCMStub([mockedTrustbadge showTrustcard]);
			id mockedImageView = OCMClassMock([UIImageView class]);
			OCMStub([[mockedImageView ignoringNonObjectArgs] pointInside:CGPointMake(0.0, 0.0) withEvent:[OCMArg any]]);
			testView.trustbadge = mockedTrustbadge;
			[testView.offlineMarker setHidden:YES];
			UITouch *aTouch = [UITouch new];
			[testView touchesEnded:[NSSet setWithObject:aTouch] withEvent:[UIEvent new]];
			OCMVerifyAll(mockedTrustbadge);
			OCMVerifyAll(mockedImageView);
		});
	});
	
	context(@"touch events when hidden", ^{
		// note: the Documentation says we're supposed to implement all touch methods
		// but when we're hidden, we just pass them through, so only test that
		__block id superViewClassMock;
		__block TRSTrustbadgeView *testView;
		beforeEach(^{
			superViewClassMock = OCMClassMock([TRSTrustbadgeView superclass]);
			OCMStub([superViewClassMock touchesBegan:[OCMArg any] withEvent:[OCMArg any]]);
			testView = [[TRSTrustbadgeView alloc] init];
			[testView.offlineMarker setHidden:NO];
		});
		afterEach(^{
			[superViewClassMock stopMocking];
			superViewClassMock = nil;
			testView = nil;
		});
		
		describe(@"-touchesBegan:withEvent:", ^{
			it(@"calls the superclass's method", ^{
				[testView touchesBegan:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(superViewClassMock);
			});
		});
		
		describe(@"-touchesMoved:withEvent:", ^{
			it(@"calls the superclass's method", ^{
				[testView touchesMoved:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(superViewClassMock);
			});
		});
		
		// this actually does something when seal is not hidden, but we don't test that for now (better for a regression test)
		describe(@"-touchesEnded:withEvent:", ^{
			it(@"calls the superclass's method", ^{
				[testView touchesEnded:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(superViewClassMock);
			});
		});
		
		describe(@"-touchesCancelled:withEvent:", ^{
			it(@"calls the superclass's method", ^{
				[testView touchesCancelled:[NSSet new] withEvent:[UIEvent new]];
				OCMVerifyAll(superViewClassMock);
			});
		});
	});
});

SpecEnd
