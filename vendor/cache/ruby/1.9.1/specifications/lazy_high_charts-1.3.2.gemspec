# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "lazy_high_charts"
  s.version = "1.3.2"

  s.required_rubygems_version = Gem::Requirement.new("~> 1.3") if s.respond_to? :required_rubygems_version=
  s.authors = ["Miguel Michelson Martinez", "Deshi Xiao"]
  s.date = "2012-11-22"
  s.description = "    lazy_high_charts is leading edge rubyist render charts gem for displaying Highcharts graphs.\n"
  s.email = ["miguelmichelson@gmail.com", "xiaods@gmail.com"]
  s.extra_rdoc_files = ["README.md", "CHANGELOG.md"]
  s.files = ["README.md", "CHANGELOG.md"]
  s.homepage = "https://github.com/xiaods/lazy_high_charts"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "rubyist way to render variant chart by highcharts without write javascript right now, rails gem library."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bundler>, ["~> 1.0"])
      s.add_runtime_dependency(%q<hash-deep-merge>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<hash-deep-merge>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<hash-deep-merge>, [">= 0"])
  end
end
