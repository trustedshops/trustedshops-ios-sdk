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

@interface TRSViewGalleryController ()

@property (nonatomic, strong) NSMutableArray *loadedViews;
@property (nonatomic, assign) NSUInteger loadingViewsCount;

@property (weak, nonatomic) IBOutlet UIView *sealPlaceholder;
- (IBAction)loadSeal:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *shopRatingPlaceholder;
- (IBAction)loadShopRating:(id)sender;

@end

@implementation TRSViewGalleryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.loadedViews = [NSMutableArray new];
	self.loadingViewsCount = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	// remove all loaded views
	for (UIView *view in self.loadedViews) {
		[view removeFromSuperview];
	}
}

- (void)willLoadAView {
	self.loadingViewsCount++;
	if (self.loadingViewsCount > 0) {
		// prevent prematurely allowing to go back (before loading requests have finished)
		UIViewController *neighbor = [self.tabBarController.viewControllers firstObject];
		neighbor.tabBarItem.enabled = NO;
	}
}

- (void)didLoadView:(UIView *)view forParent:(UIView *)parent {
	if (parent) { // on success
		[self.loadedViews addObject:view];
		[parent addSubview:view];
	}
	
	self.loadingViewsCount--;
	if (self.loadingViewsCount <= 0) {
		UIViewController *neighbor = [self.tabBarController.viewControllers firstObject];
		neighbor.tabBarItem.enabled = YES;
	}
}
- (IBAction)loadSeal:(id)sender {
	NSString *chDemoTSID = @"X330A2E7D449E31E467D2F53A55DDD070";
	CGRect tbFrame = self.sealPlaceholder.frame;
	tbFrame.origin.x = 0.0;
	tbFrame.origin.y = 0.0;
	TRSTrustbadgeView *tbView = [[TRSTrustbadgeView alloc] initWithFrame:tbFrame trustedShopsID:chDemoTSID apiToken:@"N/A"];
	[self willLoadAView];
	[tbView loadTrustbadgeWithSuccessBlock:^{
		[self didLoadView:tbView forParent:self.sealPlaceholder];
	} failureBlock:^(NSError *error) {
		NSLog(@"could not load TRSTrustbadgeView, error: %@", error);
		[self didLoadView:tbView forParent:nil];
	}];
}

- (IBAction)loadShopRating:(id)sender {
	CGRect srFrame = self.shopRatingPlaceholder.frame;
	srFrame.origin = CGPointZero;
	TRSShopRatingView *srView = [[TRSShopRatingView alloc] initWithFrame:srFrame];
	[self.shopRatingPlaceholder addSubview:srView];
	[self.loadedViews addObject:srView];
}

@end
