Pod::Spec.new do |s|
  s.name         = "LWSideMenu"
  s.version      = "0.1"
  s.platform 	 = :ios
  s.ios.deployment_target = '7.0'
  s.license      = 'MIT'
  s.summary      = "A simple slide in/out side menu using UIKitDynamics"
  s.homepage     = "https://github.com/lukaswelte/LWSideMenu"
  s.author       = { 'Lukas Welte' => 'ich@lukaswelte.de' }
  s.source       = { :git => "https://github.com/lukaswelte/LWSideMenu.git", :tag => "0.1" }
  s.source_files =  'LWSideMenu'
  s.requires_arc = true
end