Pod::Spec.new do |s|
  s.name             = 'Mimir'
  s.version          = '0.0.4'
  s.summary          = 'Mimir is a logging framework that is intended for high usage apps.'
  s.description      = <<-DESC
Mimir is a logging framework that is intended for high usage apps that require constant logging while maintaining logs in a small sized file. 
This is done by logging to 2 separate text files - a truncated and an extended text file. The most recent logs will be saved fully to the extended text file, while the older logs will be in the truncated text file which limits the length of each log by the configured size.
                       DESC
  s.homepage         = 'https://github.com/amereid/Mimir'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Amer Eid' => 'amereid92@gmail.com' }
  s.source           = { :git => 'https://github.com/amereid/Mimir.git', :tag => s.version.to_s }

  s.swift_versions = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'Mimir/Classes/**/*'
end
