//
//  NSURL+TRSURLExtensionsSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 21/03/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "NSURL+TRSURLExtensions.h"
#import <OCMock/OCMock.h>
#import <Specta/Specta.h>
#import "TRSShop.h"
#import "TRSNetworkAgent+Trustbadge.h"

SpecBegin(NSURL_TRSURLExtensions)

describe(@"NSURL+TRSURLExtensions", ^{
	__block NSURL *profileURL;
	__block NSURL *trustMarkURL;
	__block TRSShop *testShop;
	beforeAll(^{
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
		NSData *data = [NSData dataWithContentsOfFile:path];
		NSDictionary *shopData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		testShop = [[TRSShop alloc] initWithDictionary:shopData[@"response"][@"data"][@"shop"]];
		profileURL = [NSURL profileURLForShop:testShop];
		trustMarkURL = [NSURL trustMarkAPIURLForTSID:testShop.tsId andAPIEndPoint:TRSAPIEndPoint];
	});
	
	afterAll(^{
		profileURL = nil;
		testShop = nil;
		trustMarkURL = nil;
	});
	
	describe(@"+profileURLForShop:", ^{
		
		it(@"returns an NSURL", ^{
			expect([NSURL profileURLForShop:testShop]).to.beKindOf([NSURL class]);
		});
		
		it(@"has the correct prefix", ^{
			NSString *urlString = [profileURL absoluteString];
			expect([urlString hasPrefix:@"https://www.trustedshops."]).to.equal(YES);
		});
		
		it(@"contains the shop's TSID", ^{
			NSString *urlString = [profileURL absoluteString];
			expect([urlString containsString:testShop.tsId]).to.equal(YES);
		});
		
		it(@"points to a html file", ^{
			expect([profileURL pathExtension]).to.equal(@"html");
		});
	});
	
	describe(@"+trustMarkAPIURLForTSID:andAPIEndPoint:", ^{
		
		it(@"returns an NSURL", ^{
			expect([NSURL trustMarkAPIURLForTSID:testShop.tsId andAPIEndPoint:TRSAPIEndPoint]).to.beKindOf([NSURL class]);
		});
		
		it(@"has the correct prefix", ^{
			NSString *urlString = [trustMarkURL absoluteString];
			expect([urlString hasPrefix:[NSString stringWithFormat:@"https://%@", TRSAPIEndPoint]]).to.equal(YES);
		});
		
		it(@"contains the shop's TSID", ^{
			NSString *urlString = [trustMarkURL absoluteString];
			expect([urlString containsString:testShop.tsId]).to.equal(YES);
		});
		
		it(@"points to json", ^{
			expect([trustMarkURL pathExtension]).to.equal(@"json");
		});
	});
});

SpecEnd
