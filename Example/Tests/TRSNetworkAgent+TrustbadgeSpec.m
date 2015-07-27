#import "TRSNetworkAgent+Trustbadge.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>


SpecBegin(TRSNetworkAgent_Trustbadge)

describe(@"TRSNetworkAgent+Trustbadge", ^{

    __block TRSNetworkAgent *agent;
    beforeAll(^{
        agent = [[TRSNetworkAgent alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost/"]];
    });

    afterAll(^{
        agent = nil;
    });

    describe(@"-getTrustbadgeForTrustedShopsID:success:failure", ^{

        it(@"returns a data task", ^{
            id task = [agent getTrustbadgeForTrustedShopsID:nil success:nil failure:nil];
            expect(task).to.beKindOf([NSURLSessionDataTask class]);
        });

        it(@"has the correct URL", ^{
            NSURLSessionDataTask *task = (NSURLSessionDataTask *)[agent getTrustbadgeForTrustedShopsID:@"123" success:nil failure:nil];
            expect(task.originalRequest.URL).to.equal([NSURL URLWithString:@"http://localhost/rest/public/v2/shops/123/quality"]);
        });

        it(@"calls '-GET:success:failure'", ^{
            id agentMock = OCMPartialMock(agent);
            OCMExpect([agentMock GET:@"/rest/public/v2/shops/123/quality" success:[OCMArg any] failure:[OCMArg any]]);

            [agent getTrustbadgeForTrustedShopsID:@"123" success:nil failure:nil];

            OCMVerifyAll(agentMock);
        });

        context(@"on success", ^{

            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return YES;
                } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    return [OHHTTPStubsResponse responseWithData:[[NSString stringWithFormat:@"success"] dataUsingEncoding:NSUTF8StringEncoding]
                                                      statusCode:200
                                                         headers:nil];
                }];
            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });

            it(@"executes the success block", ^{
                waitUntil(^(DoneCallback done) {
                    [agent getTrustbadgeForTrustedShopsID:@"123"
                                                  success:^(id trustbadge) {
                                                      done();
                                                  }
                                                  failure:nil];
                });
            });

            it(@"passes a model object", ^{
                waitUntil(^(DoneCallback done) {
                    [agent getTrustbadgeForTrustedShopsID:@"123"
                                                  success:^(id trustbadge) {
                                                      expect(trustbadge).notTo.beNil();
                                                      done();
                                                  }
                                                  failure:nil];
                });
            });

        });

        context(@"on failure", ^{

            it(@"executes the failuer block", ^{
                waitUntil(^(DoneCallback done) {
                    [agent getTrustbadgeForTrustedShopsID:@"error"
                                                  success:nil
                                                  failure:^(NSError *error) {
                                                      done();
                                                  }];
                });
            });

            it(@"passes an error object", ^{
                waitUntil(^(DoneCallback done) {
                    [agent getTrustbadgeForTrustedShopsID:@"error"
                                                  success:nil
                                                  failure:^(NSError *error) {
                                                      expect(error).notTo.beNil();
                                                      done();
                                                  }];
                });
            });

        });

    });

});

SpecEnd
