//
//  TRSTrustcard.m
//  Pods
//
//  Created by Gero Herkenrath on 14.03.16.
//
//

static NSString * const TRSCertLocalFallback = @"trustcardfallback";
static NSString * const TRSCertHTMLName = @"trustinfos";

#import "TRSTrustcard.h"
#import "TRSTrustbadge.h"
#import "TRSTrustbadgeSDKPrivate.h"
#import "NSURL+TRSURLExtensions.h"
@import CoreText;
//@import WebKit;

@interface TRSTrustcard ()


@property (weak, nonatomic) IBOutlet UIButton *certButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
// TODO: switch to the newer WKWebView class, but beware of Interface Builder when doing so

@property (weak, nonatomic) TRSTrustbadge *displayedTrustbadge;

@end

@implementation TRSTrustcard

- (void)viewDidLoad {
	[super viewDidLoad];
	// this request should allow us caching
	NSURL *cardURL;
	if (self.remoteCertLocationFolder) {
		// TODO: do the remote loading here
		cardURL = [[[NSURL URLWithString:self.remoteCertLocationFolder]
					URLByAppendingPathComponent:TRSCertHTMLName] URLByAppendingPathExtension:@"html"];
	}
	if (!cardURL) {
		cardURL = [TRSTrustbadgeBundle() URLForResource:TRSCertHTMLName
										  withExtension:@"html"
										   subdirectory:TRSCertLocalFallback];
	}
	NSMutableURLRequest *myrequest = [[NSMutableURLRequest alloc] initWithURL:cardURL
																  cachePolicy:NSURLRequestUseProtocolCachePolicy
															  timeoutInterval:10.0];
	[self.webView loadRequest:myrequest];
}

- (IBAction)buttonTapped:(id)sender {
	if ([sender tag] == 1 && self.displayedTrustbadge) { // the tag is set in Interface Builder, it's the certButton
		NSURL *targetURL = [NSURL profileURLForShop:self.displayedTrustbadge.shop];
		[[UIApplication sharedApplication] openURL:targetURL];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showInLightboxForTrustbadge:(TRSTrustbadge *)trustbadge {	
	// this is always there, but what happens if I have more than one? multi screen apps? test that somehow...
	UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
	
	self.displayedTrustbadge = trustbadge;
	self.modalPresentationStyle = UIModalPresentationPageSheet;
	UIViewController *rootVC = mainWindow.rootViewController;
	// TODO: check what happens if there is no root VC. work that out
	[rootVC presentViewController:self animated:YES completion:nil];
}

#pragma mark Font helper methods

// note, these are currently not used with the webView, but we will keep them for now.
// also, the font asset will be used by the webview, probably
+ (UIFont *)openFontAwesomeWithSize:(CGFloat)size
{
	NSString *fontName = @"fontawesome";
	UIFont *font = [UIFont fontWithName:fontName size:size];
	if (!font) {
		[[self class] dynamicallyLoadFontNamed:fontName];
		font = [UIFont fontWithName:fontName size:size];
		
		// safe fallback
		if (!font) font = [UIFont systemFontOfSize:size];
	}
	
	return font;
}

+ (void)dynamicallyLoadFontNamed:(NSString *)name
{
	NSURL *url = [TRSTrustbadgeBundle() URLForResource:name withExtension:@"ttf"];
	NSData *fontData = [NSData dataWithContentsOfURL:url];
	if (fontData) {
		CFErrorRef error;
		CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
		CGFontRef font = CGFontCreateWithDataProvider(provider);
		if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
			CFStringRef errorDescription = CFErrorCopyDescription(error);
			NSLog(@"Failed to load font: %@", errorDescription);
			CFRelease(errorDescription);
		}
		CFRelease(font);
		CFRelease(provider);
	}
}


@end
