# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "phony_rails"
  s.version = "0.1.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joost Hietbrink"]
  s.date = "2012-12-04"
  s.description = "This Gem adds useful methods to your Rails app to validate, display and save phone numbers."
  s.email = ["joost@joopp.com"]
  s.homepage = "https://github.com/joost/phony_rails"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "This Gem adds useful methods to your Rails app to validate, display and save phone numbers."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<phony>, [">= 1.7.7"])
      s.add_runtime_dependency(%q<countries>, [">= 0.8.2"])
      s.add_runtime_dependency(%q<activerecord>, [">= 3.0"])
    else
      s.add_dependency(%q<phony>, [">= 1.7.7"])
      s.add_dependency(%q<countries>, [">= 0.8.2"])
      s.add_dependency(%q<activerecord>, [">= 3.0"])
    end
  else
    s.add_dependency(%q<phony>, [">= 1.7.7"])
    s.add_dependency(%q<countries>, [">= 0.8.2"])
    s.add_dependency(%q<activerecord>, [">= 3.0"])
  end
end
