//
//  TRSTrustcard.h
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

#import <Foundation/Foundation.h>
@class TRSTrustbadge;

@interface TRSTrustcard : UIViewController

// the color used for the buttons and marks on the card (the checkmark etc.)
@property (nonatomic, weak) UIColor *themeColor;

- (void)showInLightboxForTrustbadge:(TRSTrustbadge *)trustbadge withPresentingViewController:(UIViewController *)presenter;
- (IBAction)buttonTapped:(id)sender;

@property (nonatomic, assign) BOOL debugMode;

@end
