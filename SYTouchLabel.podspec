Pod::Spec.new do |s|
  s.name         = "SYTouchLabel"
  s.version      = "0.0.3"
  s.summary      = "轻量级可点击 Label"
  s.description  = "轻量级可点击 Label"
  s.homepage     = "https://github.com/yunisSong/SYTouchLabel"
  s.license= { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Yunis" => "332963965@qq.com" }
  s.source       = { :git => "https://github.com/yunisSong/SYTouchLabel.git" }
  s.source_files = "*.{h,m}"
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

end
