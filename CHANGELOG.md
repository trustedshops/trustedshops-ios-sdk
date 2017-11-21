# Trustbadge

## Version 0.8.3

* Fixed an issues with a method that is not available before iOS 9.
* Redesigned the various view classes so their rating related data is now readable from outside the classes.

## Version 0.8.2

* Fixed a bug that could lead to a crash when a shop without any reviews tried to load a TRSShopRatingView or a TRSShopGradeView. From now on "zero grade" views are possible.

## Version 0.8.1

* Changed the nullability specifier in some unavailable init methods (see e.g. TRSOrder.h) to nonnull. This way swift projects using the pod won't give warnings for mismatched specifiers. This has no other effect.

## Version 0.8.0

* The eMail is now optional for TRSOrder objects (and thus also for TRSCustomer objects). This allows processing orders for which the App does not collect an email address itself (for example in-app purchases). See updated README file. 

## Version 0.7.0

* Changed the popup card that is shown when the user clicks on the seal image to the standard trustcard that is also used in web shops. What exactly is shown on that card also depends on what services the shop has booked at Trusted Shops.

## Version 0.6.3

* Changed an API endpoint so that the SDK pulls also the trustmark (for the seal) from a specific place created for it alone.

## Version 0.6.2

* Fixed UI of the checkout card: For some shop options the card did not resize properly since the underlying java script did not send an according event. It now has a specific event and acts on that.

## Version 0.6.1

* Changed API endpoints for product reviews in the internal API for better load balance on our servers
* Added localization data for the various strings used by the SDK ("Reviews", ...)
* Added a public category for NSString that uses the localiations to transform rating strings delivered from the API to human readable, localized strings (that can be used in the UI)
* Fixed resizing behavior of the checkout cards - the lightbox now resizes according to the cards' needs and doesn't cutt off content or leave white space anymore
* Used shorter deprecation mark in errors to reduce cluttering of the appledoc generated documentation (this is a workaround for appledoc not understanding __deprecated)

## Version 0.6.0

* Added a means to load all individual customer reviews of a given product (in TRSProduct)
* Added all necessary classes to handle this data
* Modified the example project to show how this can be used
* Consistently used a test shop TSID in the Example project (exception: the seal, since the test shop is not certified)
* Updated API Endpoint for shop grades to an SDK specific one (other endpoints will be updated in a fix, soon)
* Moved TRSStarsView to public classes so it can be easily used to show, e.g., individual product reviews

## Version 0.5.0

* Added two abstract view classes: A general base class for views loading data from TS and a subclass of that, still abstract, specializing in loading product review data
* Added two concrete subclasses of that to display product reviews (one has two modes, so three possible UI elemnts)
* Modified the example project to showcase these new views
* Added networking code to access product reviews API
* Added internal documentation on how to subclass new views from the basic abstract classes (existing shop review views will be modified in the future)
* Renamed the error codes to better suit their meaning
* Fixed the card showing insurance etc. after purchase so that its dimensions enlarge if the shown html is cutoff

## Version 0.4.1

* The checkout process now sends a flag so TS can distinguish an order incoming from the SDK

## Version 0.4.0

* Added three new view classes to display a shops grade and rating
* Modified the example project to showcase these new views
* Also reworked the internal networking to access needed API for these views

## Version 0.3.4

* Added a property to set a custom view controller responsible for displaying any modal popin views to TRSTrustbadgeView and TRSOrder

## Version 0.3.3

* Changed the required platform to iOS 8.0 instead of 8.1
* Slightly modified the Example project to reflect what "declining" means (to be improved in the future)

## Version 0.3.2

* Fixed an issue with the webView in the checkout view shifting down when the root view controller demands a navigation bar
* Disabled zooming in said webView
* Changed the example TS IDs shown in the picker (2 don't load the seal, which is intended to show how that looks)

## Version 0.3.1

* Fixed the endpoint of the trustcard HTML ressource
* Added proper debug mode for TRSOrder objects

## Version 0.3.0

* Included order object class and related classes that enable a shop app process guarantees, reviews etc. See README.md
* Minor bugfixes in existing classes
* Switched from native popover to MaryPopin pod to display webViews
* Removed NSExceptionDomains dict from example app info.plist file as it is no longer needed.
* Updated README.md to include instructions on how to process orders

## Version 0.2.1

* Updated README.md for proper usage instructions
* Removed unused assets from the bundle to slim down the pod

## Version 0.2.0

* Renamed the repository
* Used the final API-URLs for production and QA code (CDN)
* Further pdated documentation
* Increased test coverage to an acceptable level

## Version 0.2.0-beta

* Completely reworked the trustbadge to mimic the trustbadge behaviour (simple view, tap opens trustcard)
* Changed API
* Star view and ratig view are not in use at the moment
* Included model classes for shop and trustmark
* Reworked URL handling, added needed stuff for the new concept
* Refactored tests to accomodate for new concept
* Implemented way to handle possible client-token for API
* Updated documentation in header files

## Version 0.1.0

* Use fixed decimal separator

## Version 0.1.0-beta

* Rename Pod to Trustbadge
* Language Support for de, en, es, fr, it, nl and pl-PL
* Trustbadge Border
* Trustbadge error logging
* Trustbadge view
* Refactor Tests
* Update cocoapods
* Pass `TRSTrustbadge` Object
* Add Trustbadge Model
* Accept JSON
* minor spec improvements (Thanks @DerLobi)
* Add Error Handling
* Basic Trustbadge Agent
* Change Import of Specta
* Improve the network layer
* Add Network Agent
