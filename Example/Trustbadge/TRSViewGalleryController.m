//
//  TRSViewGalleryController.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 07/06/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "TRSViewGalleryController.h"
@import Trustbadge.TRSTrustbadgeView;
@import Trustbadge.TRSShopRatingView;
@import Trustbadge.TRSShopGradeView;
@import Trustbadge.TRSShopSimpleRatingView;
@import Trustbadge.TRSProductSimpleRatingView;
@import Trustbadge.TRSProductRatingView;

@interface TRSViewGalleryController ()

@property (nonatomic, strong) NSMutableArray *loadedViews;
@property (nonatomic, strong) NSMutableArray *tappedLoadButtons;
@property (nonatomic, assign) NSUInteger loadingViewsCount;

@property (weak, nonatomic) IBOutlet UIView *sealPlaceholder;
- (IBAction)loadSeal:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *shopRatingPlaceholder;
- (IBAction)loadShopRating:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *shopGradePlaceholder;
- (IBAction)loadShopGrade:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *shopSimpleRatingPlaceholder;
- (IBAction)loadShopSimpleRating:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *productSimpleRatingPlaceholder;
- (IBAction)loadProductSimpleRating:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *productRatingTwoLinesPlaceholder;
- (IBAction)loadProductRatingTwoLines:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *productRatingOneLinePlaceholder;
- (IBAction)loadProductRatingOneLine:(id)sender;

@end

@implementation TRSViewGalleryController

#pragma mark - Gallery view preparation & UI updates

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.loadedViews = [NSMutableArray new];
	self.tappedLoadButtons = [NSMutableArray new];
	self.loadingViewsCount = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	// remove all loaded views
	for (UIView *view in self.loadedViews) {
		[view removeFromSuperview];
	}
	[self.loadedViews removeAllObjects];
	
	// re-enable load buttons
	for (id sender in self.tappedLoadButtons) {
		[sender setEnabled:YES];
	}
	[self.tappedLoadButtons removeAllObjects];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	[coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		// I'm too lazy for a nice animation, so just update the frames after we're done. For a smoother animation
		// you should set autolayout constraints when adding the views anyways.
		for (UIView *view in self.loadedViews) {
			view.frame = view.superview.bounds;
		}
	}];
}

#pragma mark - UI helpers

- (void)willLoadAView {
	self.loadingViewsCount++;
	if (self.loadingViewsCount > 0) {
		// prevent prematurely allowing to go back (before loading requests have finished)
		UIViewController *neighbor = [self.tabBarController.viewControllers firstObject];
		neighbor.tabBarItem.enabled = NO;
	}
}

- (void)didLoadView:(UIView *)view forParent:(UIView *)parent sender:(id)sender{
	if (parent) { // on success
		[self.loadedViews addObject:view];
		[parent addSubview:view];
		if (sender) { // if wanted, disable the button that loaded (to avoid loading multiple views on top of each other)
			[self.tappedLoadButtons addObject:sender];
			[sender setEnabled:NO];
		}
	}
	
	self.loadingViewsCount--;
	if (self.loadingViewsCount <= 0) {
		UIViewController *neighbor = [self.tabBarController.viewControllers firstObject];
		neighbor.tabBarItem.enabled = YES;
	}
}

#pragma mark - Actions for Trustbadge views adding & loading

- (IBAction)loadSeal:(id)sender {
	NSString *chDemoTSID = @"X330A2E7D449E31E467D2F53A55DDD070";
	CGRect tbFrame = self.sealPlaceholder.frame;
	tbFrame.origin.x = 0.0;
	tbFrame.origin.y = 0.0;
	TRSTrustbadgeView *tbView = [[TRSTrustbadgeView alloc] initWithFrame:tbFrame trustedShopsID:chDemoTSID apiToken:@"N/A"];
	[self willLoadAView];
	[tbView loadTrustbadgeWithSuccessBlock:^{
		[self didLoadView:tbView forParent:self.sealPlaceholder sender:sender];
	} failureBlock:^(NSError *error) {
		NSLog(@"Error loading the TRSTrustbadgeView: %@", error);
		[self didLoadView:tbView forParent:nil sender:nil];
	}];
}

- (IBAction)loadShopRating:(id)sender {
	CGRect srFrame = self.shopRatingPlaceholder.frame;
	srFrame.origin = CGPointZero;
	TRSShopRatingView *srView = [[TRSShopRatingView alloc] initWithFrame:srFrame];
	srView.tsID = @"X6A4AACCD2C75E430381B2E1C4CLASSIC"; // test classic for now
	srView.apiToken = @"notneededatm";
	srView.debugMode = YES;
	[self willLoadAView];
	[srView loadShopRatingWithSuccessBlock:^{
		[self didLoadView:srView forParent:self.shopRatingPlaceholder sender:sender];
		[self.tappedLoadButtons addObject:sender];
	} failureBlock:^(NSError *error) {
		NSLog(@"Error loading the TRSShopRatingView: %@", error);
		[self didLoadView:srView forParent:nil sender:nil];
	}];
}

- (IBAction)loadShopGrade:(id)sender {
	CGRect sgFrame = self.shopGradePlaceholder.frame;
	sgFrame.origin = CGPointZero;
	TRSShopGradeView *sgView = [[TRSShopGradeView alloc] initWithFrame:sgFrame];
	sgView.tsID = @"X6A4AACCD2C75E430381B2E1C4CLASSIC"; // test classic for now
	sgView.apiToken = @"notneededatm";
	sgView.debugMode = YES;
	[self willLoadAView];
	[sgView loadShopGradeWithSuccessBlock:^{
		[self didLoadView:sgView forParent:self.shopGradePlaceholder sender:sender];
		[self.tappedLoadButtons addObject:sender];
	} failureBlock:^(NSError *error) {
		NSLog(@"Error loading the TRSShopRatingView: %@", error);
		[self didLoadView:sgView forParent:nil sender:nil];
	}];
}

- (IBAction)loadShopSimpleRating:(id)sender {
	CGRect ssrFrame = self.shopSimpleRatingPlaceholder.frame;
	ssrFrame.origin = CGPointZero;
	TRSShopSimpleRatingView *ssrView = [[TRSShopSimpleRatingView alloc] initWithFrame:ssrFrame];
	ssrView.tsID = @"X6A4AACCD2C75E430381B2E1C4CLASSIC"; // test classic for now
	ssrView.apiToken = @"notneededatm";
	ssrView.debugMode = YES;
	[self willLoadAView];
	[ssrView loadShopSimpleRatingWithSuccessBlock:^{
		[self didLoadView:ssrView forParent:self.shopSimpleRatingPlaceholder sender:sender];
		[self.tappedLoadButtons addObject:sender];
	} failureBlock:^(NSError *error) {
		NSLog(@"Error loading the TRSShopRatingView: %@", error);
		[self didLoadView:ssrView forParent:nil sender:nil];
	}];
}
- (IBAction)loadProductSimpleRating:(id)sender {
	CGRect psrFrame = self.productSimpleRatingPlaceholder.frame;
	psrFrame.origin = CGPointZero;
	TRSProductSimpleRatingView *psrView = [[TRSProductSimpleRatingView alloc] initWithFrame:psrFrame
																			 trustedShopsID:@"X795C603C56D8D47D63C27CBFD94698A4"
																				   apiToken:@"notneededatm"
																						SKU:@"20610"];
	psrView.debugMode = YES;
	[self willLoadAView];
	[psrView loadViewDataFromBackendWithSuccessBlock:^{
		[self didLoadView:psrView forParent:self.productSimpleRatingPlaceholder sender:sender];
		[self.tappedLoadButtons addObject:sender];
	} failureBlock:^(NSError *error) {
		NSLog(@"Error loading the TRSProductSimpleRatingView: %@", error);
		[self didLoadView:psrView forParent:nil sender:nil];
	}];
}

- (IBAction)loadProductRatingTwoLines:(id)sender {
	CGRect pr2lFrame = self.productRatingTwoLinesPlaceholder.frame;
	pr2lFrame.origin = CGPointZero;
	TRSProductRatingView *pr2lView = [[TRSProductRatingView alloc] initWithFrame:pr2lFrame
																  trustedShopsID:@"X795C603C56D8D47D63C27CBFD94698A4"
																		apiToken:@"notneededatm"
																			 SKU:@"20610"];
	pr2lView.debugMode = YES;
	[self willLoadAView];
	[pr2lView loadViewDataFromBackendWithSuccessBlock:^{
		[self didLoadView:pr2lView forParent:self.productRatingTwoLinesPlaceholder sender:sender];
		[self.tappedLoadButtons addObject:sender];
	} failureBlock:^(NSError *error) {
		NSLog(@"Error loading the TRSProductRatingView (2 line): %@", error);
		[self didLoadView:pr2lView forParent:nil sender:nil];
	}];
}
- (IBAction)loadProductRatingOneLine:(id)sender {
	CGRect pr1lFrame = self.productRatingOneLinePlaceholder.frame;
	pr1lFrame.origin = CGPointZero;
	TRSProductRatingView *pr1lView = [[TRSProductRatingView alloc] initWithFrame:pr1lFrame
																  trustedShopsID:@"X795C603C56D8D47D63C27CBFD94698A4"
																		apiToken:@"notneededatm"
																			 SKU:@"20610"];
	pr1lView.debugMode = YES;
	pr1lView.useOnlyOneLine = YES;
	[self willLoadAView];
	[pr1lView loadViewDataFromBackendWithSuccessBlock:^{
		[self didLoadView:pr1lView forParent:self.productRatingOneLinePlaceholder sender:sender];
		[self.tappedLoadButtons addObject:sender];
	} failureBlock:^(NSError *error) {
		NSLog(@"Error loading the TRSProductRatingView (2 line): %@", error);
		[self didLoadView:pr1lView forParent:nil sender:nil];
	}];
}
@end
