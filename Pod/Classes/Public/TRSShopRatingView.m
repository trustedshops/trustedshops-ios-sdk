//
//  TRSShopRatingView.m
//  Pods
//
//  Created by Gero Herkenrath on 07/06/16.
//
//

#import "TRSShopRatingView.h"
#import "TRSRatingView.h"
#import "TRSTrustbadgeSDKPrivate.h"

// some constants for the view size constraints (these should fit the standards for a UILabel)
#define kTRSShopRatingViewGradeLabelFontSize (13.0)
#define kTRSShopRatingViewMinHeight (24.0) // twice the grade label!
#define kTRSShopRatingViewAspectRatio (5.0 / 1.0) // might be 6.0 / 1.0 with branding image in the future

@interface TRSShopRatingView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *ratingPlaceholder;
@property (nonatomic, strong) UILabel *gradeLabel; // holds text like @"4.98/5.00 (1.344 Bewertungen)"
@property (nonatomic, strong) TRSRatingView *ratingView;

@property (nonatomic, strong) NSLayoutConstraint *containerAspect;
@property (nonatomic, strong) NSLayoutConstraint *starsHeight;
@property (nonatomic, strong) NSLayoutConstraint *labelHeight;

@end

@implementation TRSShopRatingView

#pragma mark - Initialization

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
	return self;
}

- (void)finishInit {
	// frame etc. will be defined via autolayout later, values here are just placeholders
	self.containerView = [[UIView alloc] init];
	self.ratingPlaceholder = [[UIView alloc] init];
	self.gradeLabel = [[UILabel alloc] init];
	
	self.gradeLabel.font = [UIFont systemFontOfSize:kTRSShopRatingViewMinHeight / 2.0];
	NSString *gradeString = TRSLocalizedString(@"Review", @"Used in the shop rating view's grade label (singular)");
	self.gradeLabel.text = [NSString stringWithFormat:@"-/- (- %@)", gradeString];
	
	[self createConstraints];
	[self sizeToFit];
	
	// DEVELOPMENT CODE (so I can see the damn views...)
	self.ratingPlaceholder.backgroundColor = [UIColor blueColor];
//	self.gradeLabel.backgroundColor = [UIColor blueColor];
//	self.gradeLabel.text = @"4.98/5.00 (99,999 valoraciones)";
	[self.ratingPlaceholder sizeToFit];
	CGRect starsFrame = self.ratingPlaceholder.frame;
	starsFrame.origin = CGPointZero;
//	starsFrame.size = CGSizeMake(210.0, 42.0);
	starsFrame.size = CGSizeMake(105.0, 21.0);
//	kTRSShopRatingViewAspectRatio * kTRSShopRatingViewMinHeight, kTRSShopRatingViewMinHeight);
	self.ratingView = [[TRSRatingView alloc] initWithFrame:starsFrame rating:@4.6];
	[self displayRatingView:self.ratingView];
}

#pragma mark - Dynamic layout adaptation

- (CGSize)sizeThatFits:(CGSize)size {
	if (size.height < kTRSShopRatingViewMinHeight) {
		size.height = kTRSShopRatingViewMinHeight;
	}
	if (size.width < kTRSShopRatingViewMinHeight * kTRSShopRatingViewAspectRatio) {
		size.width = kTRSShopRatingViewMinHeight * kTRSShopRatingViewAspectRatio;
	}
	return size;
}

- (void)layoutSubviews {
	[self.gradeLabel sizeToFit];
	// TODO: instead of simply hiding the label, perhaps dynamically shorten it?
	if (self.gradeLabel.frame.size.width > self.frame.size.width) {
		// note: important to remove this constraint first!
		[self.gradeLabel removeConstraint:self.labelHeight];
		self.gradeLabel.hidden = YES;
		self.containerAspect.constant = 0.0;
		self.starsHeight.constant = 0.0;
	} else {
		if ([self.gradeLabel.constraints containsObject:self.labelHeight]) {
			[self.gradeLabel addConstraint:self.labelHeight];
		}
		self.gradeLabel.hidden = NO;
		self.containerAspect.constant = kTRSShopRatingViewMinHeight / 2.0; // see constraint construction below
		self.starsHeight.constant = kTRSShopRatingViewMinHeight / -2.0;
	}
	[super layoutSubviews];
}

#pragma mark - Loading values & adding stars

- (void)displayRatingView:(TRSRatingView *)rView {
	rView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.ratingPlaceholder addSubview:rView];
	[self.ratingPlaceholder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rView]-0-|"
																				   options:NSLayoutFormatDirectionLeadingToTrailing
																				   metrics:nil
																					 views:NSDictionaryOfVariableBindings(rView)]];
	[self.ratingPlaceholder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rView]-0-|"
																				   options:NSLayoutFormatDirectionLeadingToTrailing
																				   metrics:nil
																					 views:NSDictionaryOfVariableBindings(rView)]];
}

#pragma mark - Constraint setup

- (void)createConstraints {
	
	// prepare for autolayout...
	self.ratingPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
	self.gradeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
	
	// build up the view hierarchy
	[self.containerView addSubview:self.ratingPlaceholder];
	[self.containerView addSubview:self.gradeLabel];
	[self addSubview:self.containerView];
	
	// first define the aspect ratio we always have on the container view (basically a result from the rating view)
	self.containerAspect
	= [NSLayoutConstraint constraintWithItem:_containerView
								   attribute:NSLayoutAttributeHeight
								   relatedBy:NSLayoutRelationEqual
									  toItem:_containerView
								   attribute:NSLayoutAttributeWidth
								  multiplier:1.0 / kTRSShopRatingViewAspectRatio
									constant:kTRSShopRatingViewMinHeight / 2.0]; // the size for the grading label
	
	// this is important to show the rating view at all (its height is not defined otherwise!)
	NSLayoutConstraint *minContainerHeight
	= [NSLayoutConstraint constraintWithItem:_containerView
								   attribute:NSLayoutAttributeHeight
								   relatedBy:NSLayoutRelationGreaterThanOrEqual
									  toItem:nil
								   attribute:NSLayoutAttributeNotAnAttribute
								  multiplier:1.0
									constant:kTRSShopRatingViewMinHeight];
	
	// ensure the gradeLabel has the correct height needed for its font
	self.labelHeight
	= [NSLayoutConstraint constraintWithItem:_gradeLabel
								   attribute:NSLayoutAttributeHeight
								   relatedBy:NSLayoutRelationEqual
									  toItem:nil
								   attribute:NSLayoutAttributeNotAnAttribute
								  multiplier:1.0
									constant:kTRSShopRatingViewMinHeight / 2.0];
	
	// together with the previous two this defines the height for the rating view (would be 0 otherwise!)
	self.starsHeight
	= [NSLayoutConstraint constraintWithItem:_ratingPlaceholder
								   attribute:NSLayoutAttributeHeight
								   relatedBy:NSLayoutRelationEqual
									  toItem:_containerView
								   attribute:NSLayoutAttributeHeight
								  multiplier:1.0
									constant:kTRSShopRatingViewMinHeight / -2.0]; // the label again
	
	// this is not done in the rating view, but the way it's constructed this always works out)
	NSLayoutConstraint *starsAspect
	= [NSLayoutConstraint constraintWithItem:_ratingPlaceholder
								   attribute:NSLayoutAttributeHeight
								   relatedBy:NSLayoutRelationEqual
									  toItem:_ratingPlaceholder
								   attribute:NSLayoutAttributeWidth
								  multiplier:1.0 / 5.0
									constant:0.0];
	
	// add all so far
	[_containerView addConstraints:@[_containerAspect, minContainerHeight, _starsHeight]];
	[_gradeLabel addConstraint:_labelHeight];
	[_ratingPlaceholder addConstraints:@[starsAspect]];

	// do alignment
	[self.containerView addConstraints:[NSLayoutConstraint
										constraintsWithVisualFormat:@"V:|-0-[_ratingPlaceholder]-0-[_gradeLabel]-0-|"
										options:NSLayoutFormatDirectionLeadingToTrailing
										metrics:nil
										views:NSDictionaryOfVariableBindings(_ratingPlaceholder, _gradeLabel)]];
	[self.containerView addConstraints:[NSLayoutConstraint
										constraintsWithVisualFormat:@"H:[_ratingPlaceholder]-0-|"
										options:NSLayoutFormatDirectionLeadingToTrailing
										metrics:nil
										views:NSDictionaryOfVariableBindings(_ratingPlaceholder)]];
	[self.containerView addConstraints:[NSLayoutConstraint
										constraintsWithVisualFormat:@"H:[_gradeLabel]-0-|"
										options:NSLayoutFormatDirectionLeadingToTrailing
										metrics:nil
										views:NSDictionaryOfVariableBindings(_gradeLabel)]];
	
	// lastly: center container in view with aspect fit! (long ass list of constraints, hence own method)
	[self aspectFittedCenteringOfView:_containerView inParent:self];

}

- (void)aspectFittedCenteringOfView:(UIView *)view inParent:(UIView *)parent {
	NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:view
															   attribute:NSLayoutAttributeCenterX
															   relatedBy:NSLayoutRelationEqual
																  toItem:parent
															   attribute:NSLayoutAttributeCenterX
															  multiplier:1.0
																constant:0.0];
	NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:view
															   attribute:NSLayoutAttributeCenterY
															   relatedBy:NSLayoutRelationEqual
																  toItem:parent
															   attribute:NSLayoutAttributeCenterY
															  multiplier:1.0
																constant:0.0];
	NSLayoutConstraint *lessOrEqualWidth = [NSLayoutConstraint constraintWithItem:view
																		attribute:NSLayoutAttributeWidth
																		relatedBy:NSLayoutRelationLessThanOrEqual
																		   toItem:parent
																		attribute:NSLayoutAttributeWidth
																	   multiplier:1.0
																		 constant:0.0];
	NSLayoutConstraint *equalWidthHighP = [NSLayoutConstraint constraintWithItem:view
																	   attribute:NSLayoutAttributeWidth
																	   relatedBy:NSLayoutRelationEqual
																		  toItem:parent
																	   attribute:NSLayoutAttributeWidth
																	  multiplier:1.0
																		constant:0.0];
	equalWidthHighP.priority = UILayoutPriorityDefaultHigh; // this is very important!
	NSLayoutConstraint *lessOrEqualHeight = [NSLayoutConstraint constraintWithItem:view
																		 attribute:NSLayoutAttributeHeight
																		 relatedBy:NSLayoutRelationLessThanOrEqual
																			toItem:parent
																		 attribute:NSLayoutAttributeHeight
																		multiplier:1.0
																		  constant:0.0];
	NSLayoutConstraint *equalHeightHighP = [NSLayoutConstraint constraintWithItem:view
																		attribute:NSLayoutAttributeHeight
																		relatedBy:NSLayoutRelationEqual
																		   toItem:parent
																		attribute:NSLayoutAttributeHeight
																	   multiplier:1.0
																		 constant:0.0];
	equalHeightHighP.priority = UILayoutPriorityDefaultHigh; // this is very important!
	
	[parent addConstraints:@[centerX, centerY, lessOrEqualWidth, lessOrEqualHeight, equalWidthHighP, equalHeightHighP]];
}

@end
