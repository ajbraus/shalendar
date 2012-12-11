# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "powify"
  s.version = "0.8.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Seth Vargo"]
  s.date = "2012-01-17"
  s.description = "Powify provides an easy wrapper for use with 37 signal's pow. Use this gem to easily install and update pow server. Easily create, destroy, and manage pow apps."
  s.email = "sethvargo@gmail.com"
  s.executables = ["powify"]
  s.files = ["bin/powify"]
  s.homepage = "https://github.com/sethvargo/powify"
  s.require_paths = ["lib"]
  s.rubyforge_project = "powify"
  s.rubygems_version = "1.8.24"
  s.summary = "Powify is an easy-to-use wrapper for 37 signal's pow"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
  end
end
