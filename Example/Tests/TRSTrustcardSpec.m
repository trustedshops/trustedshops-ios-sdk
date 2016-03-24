//
//  TRSTrustcardSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 22/03/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "TRSTrustcard.h"
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import "TRSTrustbadge.h"
#import "NSURL+TRSURLExtensions.h"

SpecBegin(TRSTrustcard)

describe(@"TRSTrustcard", ^{
	
	__block TRSTrustcard *testCard;
	__block TRSTrustbadge *testBadge;
	beforeAll(^{
		testCard = [[TRSTrustcard alloc] init];
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
		NSData *data = [NSData dataWithContentsOfFile:path];
		testBadge = [[TRSTrustbadge alloc] initWithData:data];
	});
	afterAll(^{
		testCard = nil;
		testBadge = nil;
	});
	
	describe(@"-init", ^{

		it(@"is a subclass of UIViewController", ^{
			expect([testCard class]).to.beSubclassOf([UIViewController class]);
		});
		
		it(@"is an instance of TRSTrustcard", ^{
			expect(testCard).to.beKindOf([TRSTrustcard class]);
		});
		
		it(@"has a remoteCerLocationFolder property that's nil", ^{
			expect(testCard.remoteCertLocationFolder).toNot.beNil;
		});
		
	});
	
	describe(@"-showInLightboxForTrustbadge:", ^{
		
		afterAll(^{
			[testCard buttonTapped:nil]; // need to close the card again and get into correct state
		});
		
		it(@"calls viewDidLoad", ^{
			id cardMock = OCMPartialMock(testCard);
			OCMExpect([cardMock viewDidLoad]);
			[testCard showInLightboxForTrustbadge:testBadge];
			OCMVerifyAll(cardMock);
		});
		
		// note: for now I don't test for viewWillAppear:, because it is called asynchronously and that's a pain
	});
	
	describe(@"-buttonTapped:", ^{
		
		context(@"while trustcard is showing", ^{
			
			beforeAll(^{
				[testCard showInLightboxForTrustbadge:testBadge];
				// the closing of the card is done in the tests
			});
			
			context(@"sender has tag of 1", ^{
				
				it(@"tries to open a URL in Safari", ^{
					NSURL *shopURL = [NSURL profileURLForShop:testBadge.shop];
					UIButton *testButton = [UIButton new];
					testButton.tag = 1;
					id appMock = OCMPartialMock([UIApplication sharedApplication]);
					OCMExpect([appMock openURL:shopURL]);
					[testCard buttonTapped:testButton];
					OCMVerifyAll(appMock);
				});
			});
			
			it(@"has a presenting view controller", ^{
				expect(testCard.presentingViewController).toNot.beNil;
			});
			
			it(@"calls dismissViewControllerAnimated:completion: on the presenting VC", ^{
				id vcMock = OCMPartialMock(testCard.presentingViewController); // prev test ensures it's not nil
				OCMExpect([[vcMock ignoringNonObjectArgs] dismissViewControllerAnimated:NO completion:[OCMArg any]]);
				[testCard buttonTapped:nil];
				OCMVerifyAll(vcMock);
			});
		});
		
		context(@"while trustcard is not showing", ^{
			
			it(@"doesn't have a presenting view controller", ^{
				expect(testCard.presentingViewController).to.beNil;
			});
		});
		
	});
	
});

SpecEnd
