Pod::Spec.new do |s|
  s.name         = "FlightAnimator"
  s.version      = "0.9.1"
  s.summary      = "Natural Animation Engine on Top of Core Animation"
  s.homepage     = "https://github.com/AntonTheDev/FlightAnimator/"
  s.license      = 'MIT'
  s.author       = { "Anton Doudarev" => "antonthedev@gmail.com" }
  s.source       = { :git => 'https://github.com/AntonTheDev/FlightAnimator.git', :branch => 'dev' }
  
  s.platform     = :ios, "8.0"
  s.platform     = :tvos, "9.0"

  s.framework    = 'FlightAnimator'
  s.dependency 'CoreFlightAnimation', :git => 'https://github.com/AntonTheDev/CoreFlightAnimation.git'
  
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
 
  s.source_files = "Source/*.swift"
end
