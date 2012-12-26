# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "twilio-rb"
  s.version = "2.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stevie Graham"]
  s.date = "2012-04-15"
  s.description = "A nice Ruby wrapper for the Twilio REST API"
  s.email = "sjtgraham@mac.com"
  s.homepage = "http://github.com/stevegraham/twilio-rb"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "1.8.24"
  s.summary = "Interact with the Twilio API in a nice Ruby way."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0.5"])
      s.add_runtime_dependency(%q<httparty>, [">= 0.6.1"])
      s.add_runtime_dependency(%q<builder>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<jwt>, [">= 0.1.3"])
      s.add_development_dependency(%q<webmock>, [">= 1.6.1"])
      s.add_development_dependency(%q<rspec>, [">= 2.2.0"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.10"])
      s.add_development_dependency(%q<timecop>, [">= 0.3.5"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<i18n>, ["~> 0.5"])
      s.add_dependency(%q<httparty>, [">= 0.6.1"])
      s.add_dependency(%q<builder>, [">= 2.1.2"])
      s.add_dependency(%q<jwt>, [">= 0.1.3"])
      s.add_dependency(%q<webmock>, [">= 1.6.1"])
      s.add_dependency(%q<rspec>, [">= 2.2.0"])
      s.add_dependency(%q<mocha>, [">= 0.9.10"])
      s.add_dependency(%q<timecop>, [">= 0.3.5"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<i18n>, ["~> 0.5"])
    s.add_dependency(%q<httparty>, [">= 0.6.1"])
    s.add_dependency(%q<builder>, [">= 2.1.2"])
    s.add_dependency(%q<jwt>, [">= 0.1.3"])
    s.add_dependency(%q<webmock>, [">= 1.6.1"])
    s.add_dependency(%q<rspec>, [">= 2.2.0"])
    s.add_dependency(%q<mocha>, [">= 0.9.10"])
    s.add_dependency(%q<timecop>, [">= 0.3.5"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
  end
end
