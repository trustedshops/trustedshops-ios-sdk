# Trusted Shops SDK for iOS #

[![CI Status](https://travis-ci.org/trustedshops/trustedshops-ios-sdk.svg?branch=master)](https://travis-ci.org/trustedshops/trustedshops-ios-sdk)
[![Coverage Status](https://coveralls.io/repos/github/trustedshops/trustedshops-ios-sdk/badge.svg?branch=master)](https://coveralls.io/github/trustedshops/trustedshops-ios-sdk?branch=master)
[![Version](https://img.shields.io/cocoapods/v/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)
[![License](https://img.shields.io/cocoapods/l/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)
[![Platform](https://img.shields.io/cocoapods/p/Trustbadge.svg?style=flat)](http://cocoapods.org/pods/Trustbadge)

Integrate our SDK into your shopping app and boost your conversion with **your Trustbadge**, **your customer reviews** and **our buyer protection**:
* Show the Trustbadge in any view and size, providing additional information along with a link to your certificate.
* Show your customer ratings in different ways (as block, in a table, stars only).
* Integrate the Trusted Shops buyer protection and review collecting services into your app.

![TrustedShopsiOSSDK](https://raw.githubusercontent.com/trustedshops/trustedshops-ios-sdk/master/Screenshots/iOS-SDK.png "Boost your conversion with Trustbadge and buyer protection")

Our SDK supports the following languages: DE, EN, FR, ES, IT, NL, PL.

1. [Installation](#1-installation)
2. [Display the Trustbadge](#2-display-the-trustbadge)
3. [Display shop grade and rating](#3-display-shop-grade-and-rating)
4. [After Checkout Process](#4-after-checkout-process)
5. [About this SDK](#5-about-this-sdk)

- - - -

## 1. Installation ##

Trustbadge is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Trustbadge", "~> 0.4.1"
```

#### Example project ####
To run the example project, clone the repo, and run `pod install` from the Example directory first. You can use `pod try Trustbadge` to try out the trustbadge.

- - - -

## 2. Display the Trustbadge ##

1.Import the header

```objc
#import <Trustbadge/Trustbadge.h>
```

2.Initialize the view with your Trusted Shops ID

```objc
TRSTrustbadgeView *myTrustbadgeView = [[TRSTrustbadgeView alloc] initWithTrustedShopsID:@"YOUR-TRUSTED-SHOPS-ID" apiToken:@"SEE-BELOW-FOR-THIS"];
```

In order to get your Trusted Shops ID authorized please see the "Authorization" section below.

3.Load the trustbadge data from our backend to properly display the view

```objc
[myTrustbadgeView loadTrustbadgeWithFailureBlock:nil];
```
or
```objc
[myTrustbadgeView loadTrustbadgeWithSuccessBlock:nil failureBlock:nil];
```

You may provide blocks that are called on success and/or failure (the failure block expects an `NSError` parameter).
You can also specify a `UIColor` to customize the appearance of the trustcard that is displayed when the user taps on the trustbadge.
By default the trustbadge relies on your application's root `UIViewController` to modally display the information about your certificate. To change that set the `trustcardPresentingViewController` to a different `UIViewController`.

The trustbadge also has a `debugMode` property that, if set to `YES`, makes it load data from the Trusted Shops development API instead of the production API (the above example TS-ID works for debug and normal mode). Note that your shop's TS-ID might not be present on this API, if you need to debug with your own shop's TS-ID please contact Trusted Shops (see below).

- - - -

## 3. Display shop grade and rating

The SDK contains three additional views to display your shop's grade and rating in your app: `TRSShopRatingView`, `TRSShopSimpleRatingView`, and `TRSShopGradeView`. 

| View  | Example |
| ------------- | ------------- |
| TRSShopRatingView |![TRSShopRatingView](https://raw.githubusercontent.com/trustedshops/trustedshops-ios-sdk/master/Screenshots/TRSShopRatingView.png "TRSShopRatingView")|
| TRSShopSimpleRatingView |![TRSShopSimpleRatingView](https://raw.githubusercontent.com/trustedshops/trustedshops-ios-sdk/master/Screenshots/TRSSimpleRatingView.png "TRSShopSimpleRatingView")|
| TRSShopGradeView |![TRSShopGradeView](https://raw.githubusercontent.com/trustedshops/trustedshops-ios-sdk/master/Screenshots/TRSShopGradeView.png "TRSShopGradeView")|



They work similar to the `TRSTrustbadgeView` (`TRSShopGradeView` is an example, the other views work the same):

1.Initialize the views and set their credentials

```objc
TRSShopGradeView *myShopGradeView = [TRSShopGradeView new];
myShopGradeView.tsID = @"YOUR-TRUSTED-SHOPS-ID";
myShopGradeView.apiToken = @"THIS-IS-NOT-NEEDED-ATM"; // however, this must not be nil!
```

2.Load the data from our backend so they display something meaningful

```objc
[myShopGradeView loadShopGradeWithSuccessBlock:^{
[someParentView addSubview:myShopGradeView]; // assume someParentView is initiated somewhere else
} failureBlock:^(NSError *error) {
NSLog(@"Error loading the TRSShopRatingView: %@", error);
// your error handling
}];
```

You can customize the appearence of the views like the color of their stars via properties and they have a `debugMode` setting just like `TRSTrustbadgeView`. See the [documentation](#documentation) for further information.

- - - -

## 4. After Checkout Process

As of version 0.3.0 the SDK supports a checkout process for purchases consumers make with your app. This means you can allow them to additionally purchase a guarantee for their order from Trusted Shops, like they know it from many webshops that provide this.
Consumers will then also reminded to give reviews (if you consume this service from Trusted Shops).
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
anOrder.debugMode = YES; // see below for information on this! 

// Send the order data to Trusted Shops
// This will display a (modal) webView that displays content based on the services you bought from Trusted Shops.
// E.g., it will display a window to allow the user to purchase a guarantee. Users can always just dismiss it, of course.
[anOrder finishWithCompletionBlock:^(NSError *error) {
// handle errors and/or further process the order accoding to your app's needs
};
```

For a more detailed description of the methods and objects handling this process, see the SDK documentation.
Please be aware that in some use-cases the user may be referred to an external (mobile) website opening on Safari (for example if this is the first time they purchase a Trusted Shops guarantee). The modal WebView closes in these instances, so once they get back they can keep on using your app as usual. Like is the case with the `TRSTrustbadgeView`, you can specify a `customPresentingViewController` object to manage the presentation of the displayed dialogue boxes during the finish process.

If you are developing your application and want to test this SDK feature __please be aware that unless the order object's `debugMode` property is set to `YES`, the generated data is sent to the Trusted Shops production database!__

- - - -

## 5. About this SDK ##

#### Documentation ####
The latest documentation can be found at [cocoadocs](http://cocoadocs.org/docsets/Trustbadge/0.4.1/).
All headers are documented according to the [appledoc](http://appledoc.gentlebytes.com/appledoc/) syntax, so you can also use that to directly include the docsets into your XCode.

#### Authorization ####
To use this SDK in your own mobile app Trusted Shops needs to authorize your app.<br>
Please contact us via [productfeedback@trustedshops.com](mailto:productfeedback@trustedshops.com) to get your apps authorized.  

For testing and certification purposes the following TS-ID can be used: ```X330A2E7D449E31E467D2F53A55DDD070```

#### Data Privacy ####
Our SDK does not send or collect any user related data without prior permission from the buyer. Only if the buyer opt-in after checkout or opted-in to take advantage of the Trusted Shops guarantee in general, order information are stored for guarantee handling. Before opt-in e-mail addresses are transmitted in irreversible hashed encryption.

#### License ####
Trusted Shops Android SDK is available under the MIT license. See the LICENSE file for more info.

#### About Trusted Shops ####
Today more than 20,000 online sellers are using Trusted Shops to collect, show, and manage genuine feedback from their customers. A large community of online buyers has already contributed over 6 million reviews.
Whether you are a start-up entrepreneur, a professional seller or an international retail brand, consumer trust is a key ingredient for your business. Trusted Shops offers services that will give you the ability to highlight your trustworthiness, improve your service, and, consequently, increase your conversion rate. 

#### Questions and Feedback ####
Your feedback helps us to improve this library. 
If you have any questions concerning this product or the implementation, please contact [productfeedback@trustedshops.com](mailto:productfeedback@trustedshops.com)

#### Looking for Android? ####
https://github.com/trustedshops/trustedshops-android-sdk
