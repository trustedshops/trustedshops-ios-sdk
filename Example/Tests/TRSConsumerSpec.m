#import "TRSConsumer.h"
#import "TRSConsumer+Private.h"
#import <Specta/Specta.h>


SpecBegin(TRSConsumer)

describe(@"TRSConsumer", ^{
	
	__block TRSConsumer *testConsumer;
	
	describe(@"-init", ^{
		it(@"returns nil", ^{
			testConsumer = [[TRSConsumer alloc] init];
			expect(testConsumer).to.beNil();
		});
	});
	
	describe(@"initWithEmail:", ^{
		
		__block NSString *validMail = @"a@bc.de";
		__block NSString *weirdValidMail = @"b@d@ss@bc.de";
		__block NSString *noUserNameMail = @"@bc.de";
		__block NSString *noAtSign = @"abc.de";
		__block NSString *noTLDomain = @"a@bcde";
		
		sharedExamplesFor(@"a successful init", ^(NSDictionary *data) {
			beforeEach(^{
				testConsumer = [[TRSConsumer alloc] initWithEmail:data[@"mail"]];
			});
			afterEach(^{
				testConsumer = nil;
			});
			
			it(@"returns not nil", ^{
				expect(testConsumer).toNot.beNil();
			});
			
			it(@"returns a TRSConsumer object", ^{
				expect(testConsumer).to.beKindOf([TRSConsumer class]);
			});
			
			it(@"has the correct email field", ^{
				expect(testConsumer.email).to.equal(data[@"mail"]);
			});
			
			it(@"has unverified status", ^{
				expect(testConsumer.membershipStatus).to.equal(TRSMemberUnverified);
			});
		});
		
		context(@"with a valid email", ^{
			
			describe(@"that is normal", ^{
				itShouldBehaveLike(@"a successful init", ^{
					return @{@"mail" : validMail};
				});
			});
			
			describe(@"that is weird", ^{
				itShouldBehaveLike(@"a successful init", ^{
					return @{@"mail" : weirdValidMail};
				});
			});
			
		});
		
		context(@"with no user name in mail", ^{
			it(@"returns nil", ^{
				testConsumer = [[TRSConsumer alloc] initWithEmail:noUserNameMail];
				expect(testConsumer).to.beNil();
			});
		});
		
		context(@"with no at sign in mail", ^{
			it(@"returns nil", ^{
				testConsumer = [[TRSConsumer alloc] initWithEmail:noAtSign];
				expect(testConsumer).to.beNil();
			});
		});

		context(@"with no TL domain in mail", ^{
			it(@"returns nil", ^{
				testConsumer = [[TRSConsumer alloc] initWithEmail:noTLDomain];
				expect(testConsumer).to.beNil();
			});
		});
	});
	
});

SpecEnd
