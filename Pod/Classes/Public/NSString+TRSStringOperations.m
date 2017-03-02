//
//  NSString+TRSStringOperations.m
//  Pods
//
//  Created by Gero Herkenrath on 22/07/16.
//
//

#import "NSString+TRSStringOperations.h"
#import "TRSTrustbadgeSDKPrivate.h"

NSString *const kTRSTechnicalMarkExcellent = @"EXCELLENT";
NSString *const kTRSTechnicalMarkGood = @"GOOD";
NSString *const kTRSTechnicalMarkFair = @"FAIR";
NSString *const kTRSTechnicalMarkPoor = @"POOR";
NSString *const kTRSTechnicalMarkVeryPoor = @"VERY_POOR";
NSString *const kTRSTechnicalMarkNA = @"NOT_AVAILABLE";

@implementation NSString (TRSStringOperations)

/*
 This deserves a small explanation:
 Why do I not just add the mark strings delivered by the API to the localization files directly?
 Because they're internal logic, so they're part of the code. Also, that would mean I have to maintain the localization
 files manually and can't use genstrings (or my adapted shell script) to generate and update the strings files.
 Besides I want to be able to expose the strings as prperly typed constants in case I need to compare data somewhere
 in the program.
 */
- (NSString *)readableMarkDescription {
	NSString *retVal = nil;
	
	if ([self isEqualToString:kTRSTechnicalMarkExcellent]) {
		retVal = TRSLocalizedString(@"Excellent", @"The readable string for the 'kTRSTechnicalMarkExcellent' mark.");
	} else if ([self isEqualToString:kTRSTechnicalMarkGood]) {
		retVal = TRSLocalizedString(@"Good", @"The readable string for the 'kTRSTechnicalMarkGood' mark.");
	} else if ([self isEqualToString:kTRSTechnicalMarkFair]) {
		retVal = TRSLocalizedString(@"Fair", @"The readable string for the 'kTRSTechnicalMarkFair' mark.");
	} else if ([self isEqualToString:kTRSTechnicalMarkPoor]) {
		retVal = TRSLocalizedString(@"Poor", @"The readable string for the 'kTRSTechnicalMarkPoor' mark.");
	} else if ([self isEqualToString:kTRSTechnicalMarkVeryPoor]) {
		retVal = TRSLocalizedString(@"Very poor", @"The readable string for the 'kTRSTechnicalMarkVeryPoor' mark.");
	} else if ([self isEqualToString:kTRSTechnicalMarkNA]) {
		retVal = TRSLocalizedString(@"Not rated yet", @"The readable string for the 'kTRSTechnicalMarkNA' mark.");
	}
	
	return retVal;
}

@end
