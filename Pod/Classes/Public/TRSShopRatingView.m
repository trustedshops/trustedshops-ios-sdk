//
//  TRSShopRatingView.m
//  Pods
//
//  Created by Gero Herkenrath on 07/06/16.
//
//

#import "TRSShopRatingView.h"
#import "TRSRatingView.h"

@interface TRSShopRatingView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *ratingPlaceholder;
@property (nonatomic, strong) UILabel *gradeLabel; // holds text like @"4.98/5.00 (1.344 Bewertungen)"

@end

@implementation TRSShopRatingView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self finishInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self finishInit];
	}
}

- (void)finishInit {
	// frame etc. will be defined via autolayout later, values here are just placeholders
	self.containerView = [[UIView alloc] initWithFrame:self.frame];
	self.ratingPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 20.0)];
	self.gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 15.0)];
	
	self.gradeLabel.font = [UIFont systemFontOfSize:13.0];
	self.gradeLabel.text = @"-/- (- Bewertungen)";
	self.ratingPlaceholder.backgroundColor = [UIColor yellowColor]; // temporarily...

}

- (void)createConstraints {
	self.ratingPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
	self.gradeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self addSubview:self.containerView];
	[self.containerView addSubview:self.ratingPlaceholder];
	[self.containerView addSubview:self.gradeLabel];
	
	// plans for how the view should look:
	// 1 containerView minimum height: twice the grade label
	// 2 containerView minimum width: the gradelabel width OR 5 times the height of stars, depending on what is BIGGER
	// 3 minimum height for stars (follows from 1)
	// 4 aspect fit in self
	
//	[self.ratingPlaceholder addConstraint:[NSLayoutConstraint constraintWithItem:self.ratingPlaceholder
//																	   attribute:NSLayoutAttributeWidth
//																	   relatedBy:NSLayoutRelationEqual
//																		  toItem:self.ratingPlaceholder
//																	   attribute:NSLayoutAttributeHeight
//																	  multiplier:5.0
//																		constant:0.0]];
//	
//	[self.containerView addConstraints:[NSLayoutConstraint
//										constraintsWithVisualFormat:@"V:|-0-[_ratingPlaceholder]-0-[_gradeLabel]-0-|"
//										options:NSLayoutFormatDirectionLeadingToTrailing
//										metrics:nil
//										views:NSDictionaryOfVariableBindings(_ratingPlaceholder, _gradeLabel)]];
//	[self.containerView addConstraints:[NSLayoutConstraint
//										constraintsWithVisualFormat:@"H:[_ratingPlaceholder]-0-|"
//										options:NSLayoutFormatDirectionLeadingToTrailing
//										metrics:nil
//										views:NSDictionaryOfVariableBindings(_ratingPlaceholder)]];
//	[self.containerView addConstraints:[NSLayoutConstraint
//										constraintsWithVisualFormat:@"H:[_gradeLabel]-0-|"
//										options:NSLayoutFormatDirectionLeadingToTrailing
//										metrics:nil
//										views:NSDictionaryOfVariableBindings(_gradeLabel)]];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
