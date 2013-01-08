# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "phony"
  s.version = "1.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Hanke"]
  s.date = "2012-12-04"
  s.description = "Fast international phone number (E164 standard) normalizing, splitting and formatting. Lots of formatting options: International (+.., 00..), national (0..), and local)."
  s.email = "florian.hanke+phony@gmail.com"
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["README.textile"]
  s.homepage = "http://github.com/floere/phony"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Fast international phone number (E164 standard) normalizing, splitting and formatting."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
