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
@property (nonatomic, copy) NSString *shopID;
@property (nonatomic, copy) NSString *apiToken;

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

#warning Add your Trusted Shops ID & api token
	self.shopID = @"CHANGEME";
	self.apiToken = @"NOTNEEDEDATTHEMOMENT";
	TRSTrustbadgeView *trsTrustbadgeView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:self.shopID apiToken:self.apiToken];
	
	// Alternative 1 to fully activate the badge
	self.tableView.tableHeaderView = trsTrustbadgeView;
	trsTrustbadgeView.customColor = [UIColor colorWithRed:(54.0 / 255.0) green:(203.0 / 255.0) blue:(118.0 / 255.0) alpha:1.0];
	trsTrustbadgeView.debugMode = YES;
	[trsTrustbadgeView loadTrustbadgeWithFailureBlock:^(NSError *error) {
		NSLog(@"Error handling in example app: Error: %@", error);
	}];
	// Alternative 2 to fully activate the badge (note the preprocessor macro use!)
//	[trsTrustbadgeView loadTrustbadgeWithSuccessBlock:^{
//		NSLog(@"Success handling in example app. Loaded trustbadge, put it in table header now.");
//		trsTrustbadgeView.customColor = [UIColor colorWithRed:(54.0 / 255.0) green:(203.0 / 255.0) blue:(118.0 / 255.0) alpha:1.0];
//#ifdef DEBUG
//		trsTrustbadgeView.debugMode = YES;
//#endif
//		self.tableView.tableHeaderView = trsTrustbadgeView;
//	} failureBlock:^(NSError *error) {
//		NSLog(@"Error handling in example app: Error: %@", error);
//	}];
	
	// Creating a button to mock a purchase & set up an order object
	UIButton *purchaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
	purchaseButton.frame = CGRectMake(0.0, 0.0, 100.0, 30.0); // make it a bit larger...
	[purchaseButton setTitle:@"Purchase" forState:UIControlStateNormal];
	[purchaseButton addTarget:self action:@selector(purchaseNothing:) forControlEvents:UIControlEventTouchUpInside];
	self.tableView.tableFooterView = purchaseButton;
}

#pragma mark - Action for the fake purchase button

- (IBAction)purchaseNothing:(id)sender {
	NSDate *todayplussevendays = [[NSDate date] dateByAddingTimeInterval:1.0 * 60.0 * 60.0 * 24.0 * 7.0];
	TRSOrder *fakeOrder = [TRSOrder TRSOrderWithTrustedShopsID:self.shopID
													  apiToken:self.apiToken
														 email:@"max.mustermann@testpurchase.com"
													   ordernr:@"0815XYZ"
														amount:[NSNumber numberWithDouble:28.73]
														  curr:@"EUR"
												   paymentType:@"PREPAYMENT"
												  deliveryDate:todayplussevendays];
	
	NSURL *myURL = [NSURL URLWithString:@"http://www.brother.de/verbrauchsmaterial/laser/toner/tn/tn241c"];
	TRSProduct *product1 = [[TRSProduct alloc] initWithUrl:myURL name:@"Brother TN-241C" SKU:@"4123123"];
	product1.brand = @"Brother";
	product1.GTIN = @"4977766718400";
	myURL = [NSURL URLWithString:@"http://www.brother.de/~/media/Product%20Images/Supplies/Laser/Toner/TN/TN241C/TN241C_main.png"];
	product1.imageUrl = myURL;
	product1.MPN = @"TN241C";
	
	myURL = [NSURL URLWithString:@"http://www.brother.de/verbrauchsmaterial/laser/toner/tn/tn241c"];
	TRSProduct *product2 = [[TRSProduct alloc] initWithUrl:myURL name:@"Brother TN-261C" SKU:@"41231661"];
	
	fakeOrder.tsCheckoutProductItems = @[product1, product2];
	
	fakeOrder.debugMode = YES;
	
	[fakeOrder validateWithCompletionBlock:^(NSError *error) {
		// do some UI preparations or so?
		
		// then finish it
		[fakeOrder finishWithCompletionBlock:^(NSError *error) {
			NSLog(@"insurance %@", (fakeOrder.insuranceState == TRSUserDeclinedInsurance) ? @"declined" : @"bought");
		}];
	}];
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
