//
//  TRSCriteria.m
//  Pods
//
//  Created by Gero Herkenrath on 15/07/16.
//
//

#import "TRSCriteria.h"

@interface TRSCriteria ()

@property (nonatomic, strong, readwrite) NSNumber *mark;
@property (nonatomic, assign, readwrite) TRSCriteriaType type;

@end

@implementation TRSCriteria

- (instancetype)initWithMark:(NSNumber *)mark type:(TRSCriteriaType)type {
	self = [super init];
	if (self) {
		if ([mark floatValue] > 5.0f) {
			self.mark = @5;
		} else if ([mark floatValue] < 1.0f) {
			self.mark = @1;
		} else {
			self.mark = mark;
		}
		self.type = type;
	}
	return self;
}

- (instancetype)init
{
	return [self initWithMark:@1 type:kTRSTotal];
}

+ (TRSCriteriaType)criteriaTypeFromString:(NSString *)typeString {
	TRSCriteriaType retVal = kTRSUnknownCriteriaType;
	if ([typeString isEqualToString:@"Total"]) {
		retVal = kTRSTotal;
	}
	return retVal;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"<TRSCriteria: %p>: Mark: %@; Type: %ld", self, self.mark, (unsigned long) self.type];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TRSCriteria> Mark: %@; Type: %ld", self.mark, (unsigned long) self.type];
}

@end
