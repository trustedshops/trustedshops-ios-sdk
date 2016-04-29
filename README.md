# Trustbadge for iOS

[![CI Status](https://travis-ci.org/trustedshops/trustedshops-ios-sdk.svg?branch=master)](https://travis-ci.org/trustedshops/trustedshops-ios-sdk)
[![Coverage Status](https://coveralls.io/repos/github/trustedshops/trustedshops-ios-sdk/badge.svg?branch=master)](https://coveralls.io/github/trustedshops/trustedshops-ios-sdk?branch=master)
[![Version](https://img.shields.io/cocoapods/v/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)
[![License](https://img.shields.io/cocoapods/l/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)
[![Platform](https://img.shields.io/cocoapods/p/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)

Integrate your Trustbadge in your shopping app and show the Trusted Shops trustmark to your users and lift your conversion rate. Our SDK
- Checks the validity of your certificate in the background,
- Shows the trustbadge wherever you want in your app and
- Allows the user to get more information of the certificate's advantages by tapping on the trustbadge (a lightbox appears from which the user can access your detailled review profile)
- Currently supports the following languages: DE, EN, FR, ES, IT, NL, PL

![](https://github.com/trustedshops/trustedshops-ios-sdk/blob/master/Screenshots/iPhone-example_portrait.png)
![](https://github.com/trustedshops/trustedshops-ios-sdk/blob/master/Screenshots/iPad-example_landscape.png)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first. You can use `pod try Trustbadge` to try out the trustbadge.

## Installation

Trustbadge is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Trustbadge", "~> 0.2.1"
```

## Setup

1. Import the header

	```objc
	#import <Trustbadge/Trustbadge.h>
	```

2. Initialize the view with your Trusted Shops ID

	```objc
	TRSTrustbadgeView *myTrustbadgeView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"YOUR-TRUSTED-SHOPS-ID" apiToken:@"THIS-IS-NOT-NEEDED-ATM"];
	```
	
	In order to get your Trusted Shops ID authorized please see the "Authorization" section below. For testing purposes the following TS-ID can be used: ```X330A2E7D449E31E467D2F53A55DDD070```

3. Load the trustbadge data from our backend to properly display the view.

	```objc
	[myTrustbadgeView loadTrustbadgeWithFailureBlock:nil];
	```
	or
	```objc
	[myTrustbadgeView loadTrustbadgeWithSuccessBlock:nil failureBlock:nil];
	```

You may provide blocks that are called on success and/or failure (the failure block expects an `NSError` parameter).
You can also specify a `UIColor` to customize the appearance of the trustcard that is displayed when the user taps on the trustbadge.

The trustbadge also has a debug property that, if set to `YES`, makes it load data from the Trusted Shops development API instead of the production API (the above example TS-ID works for debug and normal mode). Note that your shop's TS-ID might not be present on this API, if you need to debug with your own shop's TS-ID please contact trusted Shops (see below).

## Authorization

To use this SDK in your own mobile app (i.e. with your own TS-ID) Trusted Shops needs to authorize your app.<br>
Please contact us via [productfeedback@trustedshops.com](mailto:productfeedback@trustedshops.com) to get your apps authorized.

## Processing purchases with Trusted Shops

![](https://github.com/trustedshops/trustedshops-ios-sdk/blob/master/Screenshots/iPhone-example-checkout.png)

As of version 0.3.0 the SDK supports a checkout process for purchases consumers make with your app. This means you can enable them to additionally purchase a guarantee for their order from Trusted Shops, like they know it from many webshops that provide this.
Consumers will then also reminded to give reviews (if you have bought this service from Trusted Shops).
To use this feature your app needs to add a few lines of code right after your checkout process:

	```objc
	// create a TRSOrder object
	TRSOrder *anOrder = [TRSOrder 
	     TRSOrderWithTrustedShopsID:@"your TS-ID"                     // your TS-ID
	                       apiToken:@"any string for now"             // just use any non-nil, non-empty string
	                          email:@"customer@example.com"           // your customer's email
	                        ordernr:@"0815XYZ"                        // a unique identifier for the order
	                         amount:[NSNumber numberWithDouble:28.73] // the total price as NSNumber
	                           curr:@"EUR"                            // the currency, see documentation for valid values
	                    paymentType:@"PREPAYMENT"                     // see documentation for valid values
	                   deliveryDate:nil];                             // this field is optional
	                   
	// optionally specify the products your customer bought
	TRSProduct *aProduct = [[TRSProduct alloc] 
	      initWithUrl:[NSURL URLWithString:@"http://www.example.com"]
	             name:@"The product's name" 
	              SKU:@"a valid SKU identifier"];
	anOrder.tsCheckoutProductItems = @[aProduct];
	
	// Send the order data to Trusted Shops
	// This will display a (modal) webView that displays content based on the services you bought from Trusted Shops.
	// E.g., it will display a window to allow the user to purchase a guarantee. Users can always just dismiss it, of course.
	[anOrder finishWithCompletionBlock:^(NSError *error) {
	    // handle errors and/or further process the order accoding to your app's needs
	};
	
	```
For a more detailed description of the methods and objects handling this process, see the SDK documentation.
Please be aware that in some use-cases the user may be referred to an external (mobile) website opening on Safari (for example if this is the first time they purchase a Trusted Shops guarantee). The modal webView closes in these instances, so once they get back they can keep on using your app as usual.

If you are developing your application and want to test this SDK feature __please be aware that unless you are in debug mode, the generated data is sent to the Trusted Shops production database!__

## Documentation

The latest documentation can be found at [cocoadocs](http://cocoadocs.org/docsets/Trustbadge/0.2.1/).
All headers are documented according to the [appledoc](http://appledoc.gentlebytes.com/appledoc/) syntax, so you can also use that to directly include the docsets into your XCode.

## About Trusted Shops

Today more than 20,000 online sellers are using Trusted Shops to collect, show, and manage genuine feedback from their customers. A large community of online buyers has already contributed over 6 million reviews.
Whether you are a start-up entrepreneur, a professional seller or an international retail brand, consumer trust is a key ingredient for your business. Trusted Shops offers services that will give you the ability to highlight your trustworthiness, improve your service, and, consequently, increase your conversion rate.

## Questions and Feedback

Your feedback helps us make this library better. If you have any questions concerning this product or the implementation, please contact productfeedback@trustedshops.com

## License
Trustbadge is available under the MIT license. See the LICENSE file for more info.

## Looking for our Android SDK?
https://github.com/trustedshops/trustedshops-android-sdk
