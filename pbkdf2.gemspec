$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'pbkdf2'

Gem::Specification.new do |s|
  s.name = 'pbkdf2'
  s.summary = 'Password-Based Key Derivation Function 2 - PBKDF2'
  s.description = 'This implementation conforms to RFC 2898, and has been tested using the test vectors in Appendix B of RFC 3962. Note, however, that while those specifications use HMAC-SHA-1, this implementation defaults to HMAC-SHA-256. (SHA-256 provides a longer bit length. In addition, NIST has stated that SHA-1 should be phased out due to concerns over recent cryptanalytic attacks.)'
  s.email = 'quigley@emerose.com'
  s.homepage = 'http://github.com/emerose/pbkdf2-ruby'
  s.authors = ['Sam Quigley']
  s.version = PBKDF2::VERSION
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdoc'
end
