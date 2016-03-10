//
//  TRSProductTableViewController.m
//  trustbadge_iOS
//
//  Created by mkalmes on 7/14/15.
//  Copyright (c) 2015 Trusted Shops GmbH. All rights reserved.
//

#import "TRSProductTableViewController.h"
#import "TRSProductDetailViewController.h"
#import "UIViewController+TRSCompatiblyLayer.h"
#import "UIViewController+TRSViewControllerShowing.m"
#import <Trustbadge/Trustbadge.h>

static NSString * const TRSProductTableViewCellReuseIdentifier = @"Product";

@interface TRSProductTableViewController ()

@property (nonatomic, copy, readwrite) NSArray *products;

@end

@implementation TRSProductTableViewController

-(void)awakeFromNib {
    self.products = @[ @{ @"title"       : @"ACME Anvil",
                          @"sku"         : @"d0d863a54e86503a047c27eaeff57cf9123b44f0",
                          @"description" : @"Uses of ACME Anvils are not limited to metalsmiths, they also can be dropped on road runner's heads" },
                       @{ @"title"       : @"ACME Axle Grease",
                          @"sku"         : @"89fd423c6cc7ff026678a2b125386464cb9f9913",
                          @"description" : @"Guaranteed slippery, ACME Axle Grease can be used as a lubricant in an endless amount of situations" },
                       @{ @"title"       : @"ACME Electric Eye",
                          @"sku"         : @"bc82bb2b02621e1e32f194808dbca48ec188cc92",
                          @"description" : @"The ACME Electric Eye is essential for all your security needs" },
                       @{ @"title"       : @"ACME Hi Speed Tonic",
                          @"sku"         : @"a05e63e1c9dfff8c7b8cae958392dca6fb749646",
                          @"description" : @"Accelerate to high speeds instantly with the ACME Hi Speed Tonic, containing vitamins R-P+M" },
                       @{ @"title"       : @"ACME Railroad Ties",
                          @"sku"         : @"1e9b1c7d6559115f022a14841460fe1b70d3596c",
                          @"description" : @"Construct your own railroad with ACME Railroad Ties (also see ACME Railroad Track)" }];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TRSProductTableViewCellReuseIdentifier];

//#warning Add your Trusted Shops ID
	NSString *shopID = @"CHANGEME";
	NSString *apiToken = @"CHANGEMETOO";
//	TRSTrustbadgeView *trsTrustbadgeView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:shopID];
	TRSTrustbadgeView *trsTrustbadgeView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:shopID apiToken:apiToken];
	
	// Alternative 1 to fully activate the badge
//	self.tableView.tableHeaderView = trsTrustbadgeView;
//	[trsTrustbadgeView loadTrustbadgeWithFailureBlock:^(NSError *error) {
//		NSLog(@"Error handling in example app: Error: %@", error);
//	}];
	// Alternative 1 to fully activate the badge
//	[trsTrustbadgeView loadTrustbadgeWithSuccessBlock:^{
//		NSLog(@"Yup, you're right, dear SDK: You got something. Thank you!");
//		self.tableView.tableHeaderView = trsTrustbadgeView; // watch out: We're doing this on the delegate queue now
//	} failureBlock:^(NSError *error) {
//		NSLog(@"Error handling in example app: Error: %@", error);
//	}];
	
	// Playground:...
	self.tableView.tableHeaderView = trsTrustbadgeView;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[trsTrustbadgeView loadTrustbadgeWithFailureBlock:^(NSError *error) {
			NSLog(@"Error handling in example app: Error: %@", error);
		}];
	});
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:TRSProductTableViewCellReuseIdentifier];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self trs_willShowingDetailViewControllerPush]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = self.products[indexPath.row][@"title"];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TRSProductDetailViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ProductDetail"];
    viewController.product = self.products[indexPath.row];

    [self tcl_showDetailViewController:viewController sender:self];
}

@end
