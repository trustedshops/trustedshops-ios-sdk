#import "TRSTrustbadge.h"
#import <Specta/Specta.h>
#import "TRSShop.h"


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
