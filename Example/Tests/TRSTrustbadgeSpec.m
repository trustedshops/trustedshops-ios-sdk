#import "TRSTrustbadge.h"
#import "TRSTrustcard.h"
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import "TRSShop.h"
#import "TRSTrustbadgeSDKPrivate.h"

@interface TRSTrustbadge (PrivateTests)

@property (nonatomic, strong) TRSTrustcard *trustcard;

@end


SpecBegin(TRSTrustbadge)

describe(@"TRSTrustbadge", ^{

    describe(@"-initWithData:", ^{

        context(@"with valid data", ^{

            __block TRSTrustbadge *trustbadge;
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"trustbadge" ofType:@"data"];
                NSData *data = [NSData dataWithContentsOfFile:path];
                trustbadge = [[TRSTrustbadge alloc] initWithData:data];
            });

            afterAll(^{
                trustbadge = nil;
            });

            it(@"returns an initialized object", ^{
                expect(trustbadge).notTo.beNil();
            });
			
			it(@"has a non nil shop property", ^{
				expect(trustbadge.shop).toNot.beNil();
			});
			
			it(@"has a TRSShop as shop property", ^{
				expect(trustbadge.shop).to.beKindOf([TRSShop class]);
			});
			
			it(@"does not yet have a trustcard property set", ^{
				expect(trustbadge.trustcard).to.beNil();
			});
			
			describe(@"-showTrustcard", ^{
				
				it(@"lazy-loads the trustcard", ^{
					// stubbing like hell...
					expect(trustbadge.trustcard).to.beNil();
					id cardMock = OCMClassMock([TRSTrustcard class]);
					id cardClassMock = OCMClassMock([TRSTrustcard class]);
					OCMStub([cardMock initWithNibName:@"Trustcard" bundle:TRSTrustbadgeBundle()]).andReturn(cardMock);
					OCMStub([cardMock showInLightboxForTrustbadge:[OCMArg any] withPresentingViewController:nil]);
					OCMStub([cardClassMock alloc]).andReturn(cardMock);
					[trustbadge showTrustcardWithPresentingViewController:nil];
					OCMVerify([cardMock showInLightboxForTrustbadge:trustbadge withPresentingViewController:nil]);
					expect(trustbadge.trustcard).toNot.beNil();
					expect(trustbadge.trustcard).to.beKindOf([TRSTrustcard class]);
					[cardMock stopMocking];
					[cardClassMock stopMocking];
				});
				
			});
			
        });

        context(@"with invalid data", ^{

            __block TRSTrustbadge *trustbadge;
            beforeAll(^{
                NSData *data = [[NSString stringWithFormat:@"invalid"] dataUsingEncoding:NSUTF8StringEncoding];
                trustbadge = [[TRSTrustbadge alloc] initWithData:data];
            });

            afterAll(^{
                trustbadge = nil;
            });

            it(@"returns nil", ^{
                expect(trustbadge).to.beNil();
            });

        });

        context(@"with nil", ^{

            __block TRSTrustbadge *trustbadge;
            beforeAll(^{
                trustbadge = [[TRSTrustbadge alloc] initWithData:nil];
            });

            afterAll(^{
                trustbadge = nil;
            });

            it(@"returns nil", ^{
                expect(trustbadge).to.beNil();
            });

        });

    });
});

SpecEnd
