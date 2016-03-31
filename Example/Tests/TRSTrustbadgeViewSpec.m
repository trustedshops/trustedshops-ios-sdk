#import "TRSTrustbadgeView.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import "NSURL+TRSURLExtensions.h"
#import "TRSErrors.h"
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <Specta/Specta.h>


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
	
    describe(@"-initWithTrustedShopsID:apiToken", ^{
		
		sharedExamplesFor(@"an initialized TRSTrustbadgeView", ^(NSDictionary *data) {
			it(@"returns a `TRSTrustbadgeView` object", ^{
				expect(data[@"trustbadgeView"]).to.beKindOf([TRSTrustbadgeView class]);
			});
			it(@"has a default color", ^{
				expect([data[@"trustbadgeView"] customColor]).toNot.beNil;
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

                view = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
                view = nil;
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
        });

        context(@"with a nil-object", ^{

            __block TRSTrustbadgeView *view;
            beforeEach(^{
                view = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:nil apiToken:nil];
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
				
				view = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
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
				
				view = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
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
				
				view = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:trustedShopsID apiToken:thisIsAFakeToken];
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

});

SpecEnd
