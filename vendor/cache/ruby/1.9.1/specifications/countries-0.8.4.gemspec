# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "countries"
  s.version = "0.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["hexorx", "Joe Corcoran"]
  s.date = "2012-11-06"
  s.description = "All sorts of useful information about every country packaged as pretty little country objects. It includes data from ISO 3166"
  s.email = ["hexorx@gmail.com"]
  s.homepage = "http://github.com/hexorx/countries"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Gives you a country object full of all sorts of useful information."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<currencies>, [">= 0.4.0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<currencies>, [">= 0.4.0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<currencies>, [">= 0.4.0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
