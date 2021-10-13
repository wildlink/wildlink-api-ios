Pod::Spec.new do |s|
  s.name             = 'Wildlink'
  s.version          = '2.0.0'
  s.summary          = 'You can use this CocoaPod to interact with the Wildlink API'

  s.homepage         = 'https://wildlink.me'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Wildfire Systems' => 'support@wildlink.me' }
  s.source           = { :git => 'https://github.com/wildlink/wildlink-api-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_versions = ['4.2', '5.0']

  #source file listsings
  s.source_files = 'Wildlink/Classes/**/*'

  #dependencies
  s.dependency 'Alamofire', '~> 5.4.4'
  
  #tests
  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Wildlink/Tests/*.swift'
      test_spec.dependency 'OHHTTPStubs', '~> 9.1.0'
      test_spec.dependency 'OHHTTPStubs/Swift', '~> 9.1.0'
  end
end
