# Trustbadge for iOS

[![CI Status](https://travis-ci.org/trustedshops/trustedshops-ios-sdk.svg?branch=master)](https://travis-ci.org/trustedshops/trustedshops-ios-sdk)
[![Coverage Status](https://coveralls.io/repos/github/trustedshops/trustedshops-ios-sdk/badge.svg?branch=master)](https://coveralls.io/github/trustedshops/trustedshops-ios-sdk?branch=master)
[![Version](https://img.shields.io/cocoapods/v/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)
[![License](https://img.shields.io/cocoapods/l/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)
[![Platform](https://img.shields.io/cocoapods/p/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)

Integrate your Trustbadge in your shopping app and show the Trusted Shops trustmark to your users and lift your conversion rate. Our SDK
- checks the validity of your certificate in the background,
- shows the trustbadge whereever you want in your app and
- allows the user to get more information of the certificate's advantages by tapping on the trustbadge (a lightbox appears from which the user can access your detailled review profile)
- currently supports the following languages: DE, EN, FR, ES, IT, NL, PL

![](https://github.com/trustedshops/trustedshops-ios-sdk/blob/master/Screenshots/iPhone-example_portrait.png)
![](https://github.com/trustedshops/trustedshops-ios-sdk/blob/master/Screenshots/iPad-example_landscape.png)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first. You can use `pod try Trustbadge` to try out the trustbadge.

## Installation

Trustbadge is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Trustbadge", "~> 0.2.0"
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
The trustbadge also has a debug property that sets it to load data from the Trusted Shops development API instead of our production API.

## Documentation

The latest documentation can be found at [cocoadocs](http://cocoadocs.org/docsets/Trustbadge/0.2.0/).

## About Trusted Shops

Today more than 20,000 online sellers are using Trusted Shops to collect, show, and manage genuine feedback from their customers. A large community of online buyers has already contributed over 6 million reviews.
Whether you are a start-up entrepreneur, a professional seller or an international retail brand, consumer trust is a key ingredient for your business. Trusted Shops offers services that will give you the ability to highlight your trustworthiness, improve your service, and, consequently, increase your conversion rate.

## Questions and Feedback

Your feedback helps us make this library better. If you have any questions concerning this product or the implementation, please contact productfeedback@trustedshops.com

## License

Trustbadge is available under the MIT license. See the LICENSE file for more info.

## Looking for Android SDK?
https://github.com/trustedshops/trustedshops-android-sdk
