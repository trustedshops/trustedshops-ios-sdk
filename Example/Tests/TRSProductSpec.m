#import <Specta/Specta.h>
#import "TRSProduct.h"

SpecBegin(TRSProduct)

describe(@"-initWithUrl:name:SKU:", ^{
	
	context(@"with valid values", ^{
		
		__block TRSProduct *testProduct;
		beforeAll(^{
			testProduct = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.google.de"]
													 name:@"testname" SKU:@"1234567890AB"];
		});
		afterAll(^{
			testProduct = nil;
		});
		
		it(@"returns not nil", ^{
			expect(testProduct).toNot.beNil();
		});
		
		it(@"returns an object of type TRSProduct", ^{
			expect(testProduct).to.beKindOf([TRSProduct class]);
		});
		
		it(@"has the correct required properties", ^{
			expect([testProduct.url absoluteString]).to.equal(@"https://www.google.de");
			expect(testProduct.name).to.equal(@"testname");
			expect(testProduct.SKU).to.equal(@"1234567890AB");
		});
		
	});
	
	context(@"with an empty name string", ^{
		it(@"returns nil", ^{
			TRSProduct *failedProduct = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.google.de"]
																   name:@"" SKU:@"1234567890AB"];
			expect(failedProduct).to.beNil();
		});
	});
	
	context(@"with an empty SKU string", ^{
		it(@"returns nil", ^{
			TRSProduct *failedProduct = [[TRSProduct alloc] initWithUrl:[NSURL URLWithString:@"https://www.google.de"]
																   name:@"testname" SKU:@""];
			expect(failedProduct).to.beNil();
		});
	});
	
});

SpecEnd
