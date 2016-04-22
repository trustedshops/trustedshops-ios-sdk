//
//  TRSCheckoutViewController.m
//  Pods
//
//  Created by Gero Herkenrath on 22/04/16.
//
//

#import "TRSCheckoutViewController.h"
#import "UIViewController+MaryPopin.h"
@import WebKit;

@interface TRSCheckoutViewController ()

@property (weak, nonatomic) WKWebView *webView; // this is just a convenience pointer..., view also holds it (strong)

@end

@implementation TRSCheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_minPopoverSize = CGSizeMake(304.0, 304.0); // for now: rely on width of a small iPhone (320)
	
}

-(void)loadView {
	if (!_webView) {
		self.view = [[WKWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, _minPopoverSize.width, _minPopoverSize.height)];
		self.webView = self.view;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processOrder:(nonnull TRSOrder *)order onCompletion:(nullable void (^)(NSError *_Nullable error))onCompletion {
	UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	if (!rootVC) {
		NSError *error = [NSError errorWithDomain:@"tobenamed" code:999
										 userInfo:@{NSLocalizedDescriptionKey : @"need a root view controller!"}];
		onCompletion(error);
		return;
	}
	
	NSURL *sampleURL = [NSURL URLWithString:@"https://www.google.de"];
	NSURLRequest *request = [NSURLRequest requestWithURL:sampleURL];
	[self.webView loadRequest:request];
	
	[rootVC presentPopinController:self animated:YES completion:nil];
}

@end
