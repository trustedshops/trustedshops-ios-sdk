#import "Specta.h"
#import "TRSNetworkAgent.h"
#import <OHHTTPStubs/OHHTTPStubs.h>


SpecBegin(TRSNetworkAgent)

describe(@"TRSNetworkAgent", ^{

    __block TRSNetworkAgent *agent;
    beforeAll(^{
        agent = [[TRSNetworkAgent alloc ] initWithBaseURL:[NSURL URLWithString:@"http://localhost"]];
    });

    afterAll(^{
        agent = nil;
    });

    it(@"has a non-nil agent", ^{
        expect(agent).toNot.beNil();
    });

    it(@"has the correct object", ^{
        expect(agent).to.beKindOf([TRSNetworkAgent class]);
    });

    it(@"has the correct base URL", ^{
        expect(agent.baseURL).to.equal([NSURL URLWithString:@"http://localhost"]);
    });

    describe(@"+sharedAgent", ^{

        it(@"has the correct base URL", ^{
            expect([TRSNetworkAgent sharedAgent].baseURL).to.equal([NSURL URLWithString:@"https://api.trustedshops.com/"]);
        });

    });

    describe(@"-GET:success:failure:", ^{

        it(@"returns a data task", ^{
            id task = [agent GET:@"foo/bar/baz" success:nil failure:nil];
            expect(task).to.beKindOf([NSURLSessionDataTask class]);
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

            it(@"calls the success block", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:@"foo/bar/baz"
                       success:^(NSData *data){
                           done();
                       }
                       failure:nil];
                });
            });

            it(@"has a data object", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:@"/foo/bar/baz"
                       success:^(NSData *data){
                           expect(data).notTo.beNil();
                           done();
                       }
                       failure:nil];
                });
            });

        });

        context(@"on failure", ^{

            it(@"calls the failure block", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:@"/foo/bar/baz"
                       success:nil
                       failure:^(NSError *error){
                           done();
                       }];
                });
            });

            it(@"has an error object", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:@"/foo/bar/baz"
                       success:nil
                       failure:^(NSError *error){
                           expect(error).notTo.beNil();
                           done();
                       }];
                });
            });

        });

    });

});

SpecEnd
