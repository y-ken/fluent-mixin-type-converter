# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-mixin-type-converter"
  spec.version       = "0.0.2"
  spec.authors       = ["Kentaro Yoshida"]
  spec.email         = ["y.ken.studio@gmail.com"]
  spec.summary       = %q{Fluentd mixin plugin to provides type conversion function as like as in_tail plugin. It acts calling Fluent::TextParser::TypeConverter as mixin. It will let you get easy to implement type conversion for your own plugins.}
  spec.homepage      = "https://github.com/y-ken/fluent-mixin-type-converter"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "fluent-mixin-rewrite-tag-name"
  spec.add_runtime_dependency "fluentd", "~> 0.10.42"
end
