# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bloggy"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Zach Bruhnke"]
  s.date = "2012-05-04"
  s.description = "Add a Jekyll blog to an existing Rails application in seconds"
  s.email = ["z@zbruhnke.com"]
  s.homepage = "http://github.com/zbruhnke/bloggy"
  s.require_paths = ["lib"]
  s.rubyforge_project = "bloggy"
  s.rubygems_version = "1.8.24"
  s.summary = "generate a jekyll blog within a rails application quickly and easily. No additonal nginx config required"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jekyll>, [">= 0"])
      s.add_runtime_dependency(%q<rdiscount>, [">= 0"])
      s.add_runtime_dependency(%q<rails>, [">= 0"])
      s.add_runtime_dependency(%q<rack-contrib>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.11"])
      s.add_development_dependency(%q<redgreen>, ["~> 1.2"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11"])
      s.add_development_dependency(%q<rr>, ["~> 1.0"])
      s.add_development_dependency(%q<cucumber>, ["= 1.1"])
      s.add_development_dependency(%q<RedCloth>, ["~> 4.2"])
      s.add_development_dependency(%q<rdiscount>, ["~> 1.6"])
      s.add_development_dependency(%q<redcarpet>, ["~> 1.9"])
    else
      s.add_dependency(%q<jekyll>, [">= 0"])
      s.add_dependency(%q<rdiscount>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 0"])
      s.add_dependency(%q<rack-contrib>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rdoc>, ["~> 3.11"])
      s.add_dependency(%q<redgreen>, ["~> 1.2"])
      s.add_dependency(%q<shoulda>, ["~> 2.11"])
      s.add_dependency(%q<rr>, ["~> 1.0"])
      s.add_dependency(%q<cucumber>, ["= 1.1"])
      s.add_dependency(%q<RedCloth>, ["~> 4.2"])
      s.add_dependency(%q<rdiscount>, ["~> 1.6"])
      s.add_dependency(%q<redcarpet>, ["~> 1.9"])
    end
  else
    s.add_dependency(%q<jekyll>, [">= 0"])
    s.add_dependency(%q<rdiscount>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 0"])
    s.add_dependency(%q<rack-contrib>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rdoc>, ["~> 3.11"])
    s.add_dependency(%q<redgreen>, ["~> 1.2"])
    s.add_dependency(%q<shoulda>, ["~> 2.11"])
    s.add_dependency(%q<rr>, ["~> 1.0"])
    s.add_dependency(%q<cucumber>, ["= 1.1"])
    s.add_dependency(%q<RedCloth>, ["~> 4.2"])
    s.add_dependency(%q<rdiscount>, ["~> 1.6"])
    s.add_dependency(%q<redcarpet>, ["~> 1.9"])
  end
end
