//
//  TRSProductReview.m
//  Pods
//
//  Created by Gero Herkenrath on 15/07/16.
//
//

#import "TRSProductReview.h"

@interface TRSProductReview ()

@property (nonatomic, strong, readwrite) NSDate *creationDate;
@property (nonatomic, copy, readwrite) NSString *comment;
@property (nonatomic, strong, readwrite) NSNumber *mark;
@property (nonatomic, copy, readwrite) NSString *UID;
@property (nonatomic, strong, readwrite) NSArray *criteria;

@end

@implementation TRSProductReview

- (instancetype)initWithCreationDate:(NSDate *)creationDate
							 comment:(NSString *)comment
								mark:(NSNumber *)mark
								 UID:(NSString *)UID
							criteria:(NSArray *)criteria {
	
	self = [super init];
	if (self) {
		_creationDate = creationDate;
		_comment = comment;
		if (!mark || [mark floatValue] < 1.0f) {
			_mark = @1;
		} else if ([mark floatValue] > 5.0f) {
			_mark = @5;
		} else {
			_mark = mark;
		}
		_UID = UID;
		_criteria = criteria;
	}
	return self;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"<TRSProductReview: %p>:\r\tcreationDate: %@;\r\tcomment: %@;\r\tmark: %@;\r\tUID: %@;\r\tcriteria: %@",
			self, self.creationDate, self.comment, self.mark, self.UID, self.criteria];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TRSProductReview>creationDate: %@; comment: %@; mark: %@; UID: %@; criteria: <NSArray: %p>",
			self.creationDate, self.comment, self.mark, self.UID, self.criteria];
}

@end
