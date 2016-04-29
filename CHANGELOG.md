# Trustbadge

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
