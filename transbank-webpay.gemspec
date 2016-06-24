# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'transbank/webpay/version'

Gem::Specification.new do |spec|
  spec.name          = "transbank-webpay"
  spec.version       = Transbank::Webpay::VERSION
  spec.authors       = ['Ramón Soto']
  spec.email         = ['ramon.soto@clouw.com']

  spec.summary       = %q{transbank webpay soap gem}
  spec.description   = %q{transbank webpay SOAP gem}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'signer'
  spec.add_dependency 'savon', '~> 2.0'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'nori'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock', '>= 1.20'
end
