Pod::Spec.new do |s|
  s.name             = "Trustbadge"
  s.version          = "0.5.0"
  s.summary          = "Trusted Shops SDK for iOS"
  s.description      = <<-DESC
                       Use the Trustbadge and Trusted Shops guarantee in your iOS app.
                       DESC
  s.homepage         = "https://github.com/trustedshops/trustedshops-ios-sdk"
  s.license          = 'MIT'
  s.author           = "Trusted Shops GmbH"
  s.source           = { :git => "https://github.com/trustedshops/trustedshops-ios-sdk.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.dependency 'MaryPopin', '~> 1.4.2'

  s.source_files        = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/Public/*.h'
  s.ios.resource_bundle = { 'TrustbadgeResources' => ['Pod/Assets/*'] }
end
