# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "icalendar"
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sean Dague"]
  s.date = "2012-11-21"
  s.description = "This is a Ruby library for dealing with iCalendar files.  Rather than\nexplaining myself, here is the introduction from RFC-2445, which\ndefines the format:\n\nThe use of calendaring and scheduling has grown considerably in the\nlast decade. Enterprise and inter-enterprise business has become\ndependent on rapid scheduling of events and actions using this\ninformation technology. However, the longer term growth of calendaring\nand scheduling, is currently limited by the lack of Internet standards\nfor the message content types that are central to these knowledgeware\napplications. This memo is intended to progress the level of\ninteroperability possible between dissimilar calendaring and\nscheduling applications. This memo defines a MIME content type for\nexchanging electronic calendaring and scheduling information. The\nInternet Calendaring and Scheduling Core Object Specification, or\niCalendar, allows for the capture and exchange of information normally\nstored within a calendaring and scheduling application; such as a\nPersonal Information Manager (PIM) or a Group Scheduling product. \n\nThe iCalendar format is suitable as an exchange format between\napplications or systems. The format is defined in terms of a MIME\ncontent type. This will enable the object to be exchanged using\nseveral transports, including but not limited to SMTP, HTTP, a file\nsystem, desktop interactive protocols such as the use of a memory-\nbased clipboard or drag/drop interactions, point-to-point asynchronous\ncommunication, wired-network transport, or some form of unwired\ntransport such as infrared might also be used."
  s.email = ["sean@dague.net"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "website/index.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "website/index.txt"]
  s.homepage = "http://github.com/sdague/icalendar"
  s.post_install_message = "PostInstall.txt"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "icalendar"
  s.rubygems_version = "1.8.24"
  s.summary = "This is a Ruby library for dealing with iCalendar files"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<hoe>, ["~> 3.3"])
    else
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<hoe>, ["~> 3.3"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<hoe>, ["~> 3.3"])
  end
end
