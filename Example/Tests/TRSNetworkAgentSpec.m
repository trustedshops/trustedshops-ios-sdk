//
//  TRSNetworkAgentSpec.m
//  trustbadge_iOS
//
//  Created by Marc Kalmes on 7/21/15.
//  Copyright 2015 Trusted Shops GmbH. All rights reserved.
//

#import "Specta.h"
#import "TRSNetworkAgent.h"
#import <OHHTTPStubs/OHHTTPStubs.h>


SpecBegin(TRSNetworkAgent)

describe(@"TRSNetworkAgent", ^{

    __block TRSNetworkAgent *agent;
    beforeAll(^{
        agent = [TRSNetworkAgent sharedAgent];
    });

    afterAll(^{
        agent = nil;
    });

    describe(@"-GET:success:failure:", ^{

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
                    [agent GET:@"http://localhost"
                       success:^(NSData *data){
                           done();
                       }
                       failure:nil];
                });
            });

            it(@"has a data object", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:@"http://localhost"
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
                    [agent GET:@"http://localhost"
                       success:nil
                       failure:^(NSError *error){
                           done();
                       }];
                });
            });

            it(@"has an error object", ^{
                waitUntil(^(DoneCallback done) {
                    [agent GET:@"http://localhost"
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
