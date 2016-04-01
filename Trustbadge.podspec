Pod::Spec.new do |s|
  s.name             = "Trustbadge"
  s.version          = "0.2.0-beta.2"
  s.summary          = "Trustbadge for iOS"
  s.description      = <<-DESC
                       Use the Trustbadge in your iOS app.
                       DESC
  s.homepage         = "https://github.com/trustedshops/trustbadge_iOS"
  s.license          = 'MIT'
  s.author           = "Trusted Shops GmbH"
  s.source           = { :git => "https://github.com/trustedshops/trustbadge_iOS.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.1'
  s.requires_arc = true

  s.source_files        = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/Public/*.h'
  s.ios.resource_bundle = { 'TrustbadgeResources' => ['Pod/Assets/*'] }
end
