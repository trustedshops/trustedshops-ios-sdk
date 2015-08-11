#import "TRSTrustbadgeView.h"
#import "TRSNetworkAgent+Trustbadge.h"
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <Specta/Specta.h>


SpecBegin(TRSTrustbadgeView)

describe(@"TRSTrustbadgeView", ^{

    __block TRSNetworkAgent *agent;
    __block id networkMock;
    beforeAll(^{
        agent = [[TRSNetworkAgent alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost/"]];
        networkMock = OCMClassMock([TRSNetworkAgent class]);
        OCMStub([networkMock sharedAgent]).andReturn(agent);
    });

    afterAll(^{
        agent = nil;
        networkMock = nil;
    });

    describe(@"-initWithTrustedShopsID:", ^{

        context(@"with a valid Trusted Shops ID", ^{

            __block TRSTrustbadgeView *view;
            beforeEach(^{
                NSString *trustedShopsID = @"999888777666555444333222111000999";

                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    NSString *URLString = [NSString stringWithFormat:@"http://localhost/rest/public/v2/shops/%@/quality", trustedShopsID];
                    BOOL shouldStubRequest = [request.URL.absoluteString isEqualToString:URLString];
                    return shouldStubRequest;
                } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                    NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    return [OHHTTPStubsResponse responseWithData:data
                                                      statusCode:200
                                                         headers:nil];
                }];

                view = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:trustedShopsID];
            });

            afterEach(^{
                [OHHTTPStubs removeAllStubs];
                view = nil;
            });

            it(@"returns a `TRSTrustbadgeView` object", ^{
                expect(view).to.beKindOf([TRSTrustbadgeView class]);
            });

            it(@"retruns the same ID", ^{
                expect(view.trustedShopsID).to.equal(@"999888777666555444333222111000999");
            });

        });

        context(@"with an unknown Trusted Shops ID", ^{
        });

        context(@"with an invalid Trusted Shops ID", ^{
        });

    });

});

SpecEnd
