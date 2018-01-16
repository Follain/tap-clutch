# frozen_string_literal: true

require File.expand_path('../lib/tap_clutch/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'tap-clutch'
  s.version      = TapClutch::VERSION
  s.platform     = Gem::Platform::RUBY
  s.date         = '2017-06-21'
  s.summary      = 'Singer.io tap for Clutch Loyalty'
  s.description  = 'Stream Clutch records to a Singer target, such as Stitch'
  s.authors      = ['Joe Lind']
  s.email        = 'joelind@gmail.com'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/Follain/tap-clutch'

  s.files        = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md']
  s.require_path = 'lib'
  s.executables  = ['tap-clutch']

  s.add_runtime_dependency 'activesupport', '~> 5.1'
  s.add_runtime_dependency 'clutch-client', '~> 0.1'
  s.add_runtime_dependency 'concurrent-ruby', '~> 1.0', '>= 1.0.2'
  s.add_runtime_dependency 'faraday-cookie_jar', '~> 0.0.6'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.12.2'
end
