# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require 'memorable/version'

Gem::Specification.new do |spec|
  spec.name          = "memorable"
  spec.version       = Memorable::VERSION
  spec.authors       = ["Xiaoguang Chen"]
  spec.email         = ["xg.chen87@gmail.com"]
  spec.summary       = "A Rails logging system based on actions."
  spec.description   = %q{A Rails logging system based on actions, instead of
                          model callbacks. Customizable ready-to-run
                          configurations and built-in I18n support.}
  spec.homepage      = "https://github.com/serco-chen/memorable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0") - %w[.gitignore]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'activesupport', '>= 3.2.8', "< 5.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
