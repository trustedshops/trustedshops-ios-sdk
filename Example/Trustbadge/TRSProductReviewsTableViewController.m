//
//  TRSProductReviewsTableViewController.m
//  Trustbadge
//
//  Created by Gero Herkenrath on 18/07/16.
//  Copyright © 2016 Trusted Shops GmbH. All rights reserved.
//

#import "TRSProductReviewsTableViewController.h"
@import Trustbadge.TRSProductReview;
@import Trustbadge.TRSStarsView;

@interface TRSProductReviewsTableViewController ()

@end

@implementation TRSProductReviewsTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reviewsToShow.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productReviewsCell" forIndexPath:indexPath];
    
	TRSProductReview *toDisplay = [self.reviewsToShow objectAtIndex:indexPath.row];
	if (toDisplay) {
		TRSStarsView *theStars = [TRSStarsView starsWithRating:toDisplay.mark];
		UIView *starsPlaceholder = [cell viewWithTag:1];
		theStars.frame = starsPlaceholder.bounds;
		[starsPlaceholder addSubview:theStars];
		UITextView *commentView = [cell viewWithTag:2];
		commentView.text = toDisplay.comment;
	}
    
    return cell;
}

@end
