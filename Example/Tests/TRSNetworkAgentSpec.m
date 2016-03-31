#import "TRSNetworkAgent.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <Specta/Specta.h>

SpecBegin(TRSNetworkAgent)

describe(@"TRSNetworkAgent", ^{

    __block TRSNetworkAgent *agent;
    beforeAll(^{
        agent = [[TRSNetworkAgent alloc] init];
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


    describe(@"+sharedAgent", ^{

        
        it(@"returns the same instance", ^{
            TRSNetworkAgent *agent1 = [TRSNetworkAgent sharedAgent];
            TRSNetworkAgent *agent2 = [TRSNetworkAgent sharedAgent];
            
            expect(agent1).to.equal(agent2);
        });

    });

    describe(@"-GET:authToken:success:failure:", ^{

        it(@"returns a data task", ^{
			id task = [agent GET:[NSURL URLWithString:@"foo/bar/baz"] authToken:@"authToken" success:nil failure:nil];
            expect(task).to.beKindOf([NSURLSessionDataTask class]);
        });

        context(@"on success", ^{

            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.absoluteString isEqualToString:@"https://localhost/foo/bar/baz"];
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
					[agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
					 authToken:@"authToken"
					   success:^(NSData *data) {
						   done();
					   } failure:nil];
				});
			});
			
			it(@"passes a data object", ^{
				waitUntil(^(DoneCallback done) {
					[agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
					 authToken:@"authToken"
					   success:^(NSData *data) {
						   expect(data).toNot.beNil;
						   done();
					   } failure:nil];
				});

			});

            it(@"accepts JSON", ^{
				NSURLSessionDataTask *task = [agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
											  authToken:@"authToken"
												success:nil
												failure:nil];
                NSDictionary *headerDictionary = task.originalRequest.allHTTPHeaderFields;

                expect(headerDictionary).to.beSupersetOf(@{@"Accept" : @"application/json"});
            });
			
			it(@"has auth Token", ^{
				NSURLSessionDataTask *task = [agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
											  authToken:@"authToken"
												success:nil
												failure:nil];
				NSDictionary *headerDictionary = task.originalRequest.allHTTPHeaderFields;
				
				expect(headerDictionary).to.beSupersetOf(@{@"client-token" : @"authToken"});
			});

            it(@"calls the success block", ^{
                waitUntil(^(DoneCallback done) {
					[agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
					 authToken:@"authToken"
                       success:^(NSData *data){
                           done();
                       }
                       failure:nil];
                });
            });

            it(@"has a data object", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
					 authToken:@"authToken"
                       success:^(NSData *data){
                           expect(data).to.equal([[NSString stringWithFormat:@"success"] dataUsingEncoding:NSUTF8StringEncoding]);
                           done();
                       }
                       failure:nil];
                });
            });

        });

        context(@"on failure", ^{

            beforeEach(^{
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.absoluteString isEqualToString:@"https://localhost/foo/bar/baz"];
                } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                    NSError *networkError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil];
                    return [OHHTTPStubsResponse responseWithError:networkError];
                }];
            });
            
            afterEach(^{
                [OHHTTPStubs removeAllStubs];
            });
            
            it(@"calls the failure block", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:[NSURL URLWithString:@"foo/bar/baz"]
					 authToken:@"authToken"
                       success:nil
                       failure:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                           done();
                       }];
                });
            });

            it(@"passes an error object with a 'NSURLErrorDomain' error domain", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:[NSURL URLWithString:@"foo/bar/baz"]
					 authToken:@"authToken"
                       success:nil
                       failure:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                           expect(error.domain).to.equal(@"NSURLErrorDomain");
                           done();
                       }];
                });
            });

            it(@"passes an error object with a 'NSURLErrorCannotConnectToHost' error code", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
					 authToken:@"authToken"
                       success:nil
                       failure:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                           expect(error.code).to.equal(NSURLErrorCannotConnectToHost);
                           done();
                       }];
                });
            });

            context(@"with a network response", ^{

                beforeEach(^{
                    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                        return [request.URL.absoluteString isEqualToString:@"https://localhost/foo/bar/baz"];
                    }
                                        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                            return [OHHTTPStubsResponse responseWithData:[[NSString stringWithFormat:@"not found"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                              statusCode:404
                                                                                 headers:nil];
                                        }];
                });

                afterEach(^{
                    [OHHTTPStubs removeAllStubs];
                });

                it(@"passes a data object", ^{
                    waitUntil(^(DoneCallback done) {
                        [agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
						 authToken:@"authToken"
                           success:nil
                           failure:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                               expect(data).to.equal([[NSString stringWithFormat:@"not found"] dataUsingEncoding:NSUTF8StringEncoding]);
                               done();
                           }];
                    });
                });

                it(@"passes a response object", ^{
                    waitUntil(^(DoneCallback done) {
                        [agent GET:[NSURL URLWithString:@"https://localhost/foo/bar/baz"]
						 authToken:@"authToken"
                           success:nil
                           failure:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                               expect(response).to.beKindOf([NSHTTPURLResponse class]);
                               done();
                           }];
                    });
                });

            });

        });

    });

});

SpecEnd
