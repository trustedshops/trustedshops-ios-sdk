//
//  NSString+TRSStringOperationsSpec.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 22/07/16.
//

#import "NSString+TRSStringOperations.h"
#import <Specta/Specta.h>

SpecBegin(NSString_TRSStringOperations)

describe(@"NSString+TRSStringOperations", ^{
	
	describe(@"-readableMarkDescription", ^{
		
		it(@"returns a string for each of the mark description constants", ^{
			NSString *excellent = kTRSTechnicalMarkExcellent;
			NSString *good =kTRSTechnicalMarkGood;
			NSString *fair = kTRSTechnicalMarkFair;
			NSString *poor = kTRSTechnicalMarkPoor;
			NSString *veryPoor = kTRSTechnicalMarkVeryPoor;
			NSString *notAvailable = kTRSTechnicalMarkNA;
			
			expect([excellent readableMarkDescription]).toNot.beNil();
			expect([good readableMarkDescription]).toNot.beNil();
			expect([fair readableMarkDescription]).toNot.beNil();
			expect([poor readableMarkDescription]).toNot.beNil();
			expect([veryPoor readableMarkDescription]).toNot.beNil();
			expect([notAvailable readableMarkDescription]).toNot.beNil();
			
			expect([excellent readableMarkDescription]).to.beKindOf([NSString class]);
			expect([good readableMarkDescription]).to.beKindOf([NSString class]);
			expect([fair readableMarkDescription]).to.beKindOf([NSString class]);
			expect([poor readableMarkDescription]).to.beKindOf([NSString class]);
			expect([veryPoor readableMarkDescription]).to.beKindOf([NSString class]);
			expect([notAvailable readableMarkDescription]).to.beKindOf([NSString class]);
		});
		
		it(@"returns nil for any other string", ^{
			expect([@"someotherString" readableMarkDescription]).to.beNil();
		});
		
	});
	
});

SpecEnd
