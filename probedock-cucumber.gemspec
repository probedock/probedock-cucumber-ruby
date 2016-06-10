# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: probedock-cucumber 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "probedock-cucumber"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Simon Oulevay (Alpha Hydrae)"]
  s.date = "2016-06-10"
  s.description = "Cucumber client to publish test results to Probe Dock, a test tracking and analysis server."
  s.email = "devops@probedock.io"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "VERSION",
    "lib/probe_dock_cucumber.rb",
    "lib/probe_dock_cucumber/config.rb",
    "lib/probe_dock_cucumber/formatter.rb",
    "lib/probedock-cucumber.rb"
  ]
  s.homepage = "https://github.com/probedock/probedock-cucumber-ruby"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.6"
  s.summary = "Cucumber client to publish test results to Probe Dock."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<probedock-ruby>, ["~> 0.2.1"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<rake-version>, ["~> 1.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.10"])
      s.add_development_dependency(%q<fakefs>, ["~> 0.6"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<rspec-its>, ["~> 1.2"])
      s.add_development_dependency(%q<rspec-collection_matchers>, ["~> 1.1"])
      s.add_development_dependency(%q<coveralls>, ["~> 0.8"])
    else
      s.add_dependency(%q<probedock-ruby>, ["~> 0.2.1"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<rake-version>, ["~> 1.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.10"])
      s.add_dependency(%q<fakefs>, ["~> 0.6"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<rspec-its>, ["~> 1.2"])
      s.add_dependency(%q<rspec-collection_matchers>, ["~> 1.1"])
      s.add_dependency(%q<coveralls>, ["~> 0.8"])
    end
  else
    s.add_dependency(%q<probedock-ruby>, ["~> 0.2.1"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<rake-version>, ["~> 1.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.10"])
    s.add_dependency(%q<fakefs>, ["~> 0.6"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<rspec-its>, ["~> 1.2"])
    s.add_dependency(%q<rspec-collection_matchers>, ["~> 1.1"])
    s.add_dependency(%q<coveralls>, ["~> 0.8"])
  end
end

