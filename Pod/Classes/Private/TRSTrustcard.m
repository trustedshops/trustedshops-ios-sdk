//
//  TRSTrustcard.m
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

#import "TRSTrustcard.h"
#import "TRSTrustbadgeSDKPrivate.h"
@import NBMaterialDialogIOS;

@interface TRSTrustcard ()

@property (nonatomic, weak) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIImageView *sealImage;

@property (weak, nonatomic) IBOutlet UILabel *cardHeader;

@property (nonatomic, weak) IBOutlet UILabel *checkmark;
@property (weak, nonatomic) IBOutlet UILabel *checkHeader;
@property (weak, nonatomic) IBOutlet UILabel *checkText;

@property (nonatomic, weak) IBOutlet UILabel *lockmark;
@property (weak, nonatomic) IBOutlet UILabel *lockHeader;
@property (weak, nonatomic) IBOutlet UILabel *lockText;

@property (nonatomic, weak) IBOutlet UILabel *bubblesmark;
@property (weak, nonatomic) IBOutlet UILabel *bubblesHeader;
@property (weak, nonatomic) IBOutlet UILabel *bubblesText;

@end

@implementation TRSTrustcard

- (instancetype)init
{
	self = [super init];
	if (self) {
		[TRSTrustbadgeBundle() loadNibNamed:@"Trustcard" owner:self options:nil];
		self.cardView.frame = CGRectMake(0.0f, 0.0f, 270.0f, 291.0f);
	}
	return self;
}

- (void)showInLightbox {
	// to come...
	NSLog(@"Would show now...");
//	NBMaterialDialog *lightbox = [[NBMaterialDialog alloc] init];
	UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
	// fallback for the unlikely case the delegate doesn't have the window set:
	if (!mainWindow) {
		mainWindow = [[[UIApplication sharedApplication] windows] firstObject];
	}
	

	
//	[lightbox showDialog:mainWindow title:@"" content:self.cardView dialogHeight:291.0f okButtonTitle:@"OK"];
	
//	showDialog(windowView: UIView, title: String?, content: UIView, dialogHeight: CGFloat?, okButtonTitle: String?, action: ((isOtherButton: Bool) -> Void)?) -> NBMaterialDialog
}

@end
