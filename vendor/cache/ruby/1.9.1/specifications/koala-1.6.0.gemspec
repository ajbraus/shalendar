# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "koala"
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Koppel"]
  s.date = "2012-12-06"
  s.description = "Koala is a lightweight, flexible Ruby SDK for Facebook.  It allows read/write access to the social graph via the Graph and REST APIs, as well as support for realtime updates and OAuth and Facebook Connect authentication.  Koala is fully tested and supports Net::HTTP and Typhoeus connections out of the box and can accept custom modules for other services."
  s.email = "alex@alexkoppel.com"
  s.extra_rdoc_files = ["readme.md", "changelog.md"]
  s.files = ["readme.md", "changelog.md"]
  s.homepage = "http://github.com/arsduo/koala"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Koala"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A lightweight, flexible library for Facebook with support for the Graph API, the REST API, realtime updates, and OAuth authentication."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.3"])
      s.add_runtime_dependency(%q<faraday>, ["~> 0.8"])
      s.add_runtime_dependency(%q<addressable>, ["~> 2.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8"])
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
    else
      s.add_dependency(%q<multi_json>, ["~> 1.3"])
      s.add_dependency(%q<faraday>, ["~> 0.8"])
      s.add_dependency(%q<addressable>, ["~> 2.2"])
      s.add_dependency(%q<rspec>, ["~> 2.8"])
      s.add_dependency(%q<rake>, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<multi_json>, ["~> 1.3"])
    s.add_dependency(%q<faraday>, ["~> 0.8"])
    s.add_dependency(%q<addressable>, ["~> 2.2"])
    s.add_dependency(%q<rspec>, ["~> 2.8"])
    s.add_dependency(%q<rake>, ["~> 0.8"])
  end
end
