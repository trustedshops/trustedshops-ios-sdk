Pod::Spec.new do |s|
  s.name             = "trustbadge_iOS"
  s.version          = "0.1.0-alpha.1"
  s.summary          = "Trustbadge for iOS"
  s.description      = <<-DESC
                       Use the Trustbadge in your iOS app.
                       DESC
  s.homepage         = "https://github.com/trustedshops/trustbadge_iOS"
  s.license          = 'MIT'
  s.author           = "Trusted Shops GmbH"
  s.source           = { :git => "https://github.com/trustedshops/trustbadge_iOS.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.ios.resource_bundle = { 'trustbadge' => ['Pod/Assets/*'] }
end
