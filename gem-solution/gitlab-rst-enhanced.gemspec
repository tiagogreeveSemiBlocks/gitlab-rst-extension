# frozen_string_literal: true

require_relative "lib/gitlab/rst_enhanced/version"

Gem::Specification.new do |s|
  s.name = "gitlab-rst-enhanced"
  s.version = Gitlab::RstEnhanced::VERSION
  s.summary = "Enhanced reStructuredText rendering for GitLab"
  s.description = "Drop-in enhanced docutils renderer for GitLab's markup pipeline: styled admonitions, tables, sidebars and more."
  s.authors = ["Tiago Greeve"]
  s.homepage = "https://github.com/tiagogreeveSemiBlocks/gitlab-rst-extension"
  s.license = "MIT"

  s.required_ruby_version = ">= 2.7"
  s.files = Dir[
    "lib/**/*.rb",
    "bin/rst2html-enhanced",
    "assets/rst-enhanced.css",
    "config/initializers/rst_enhanced.rb",
    "README.md"
  ]
  s.executables = ["rst2html-enhanced"]
  s.require_paths = ["lib"]
  s.add_development_dependency "rspec", "~> 3.12"
  s.add_development_dependency "rake", "~> 13.0"
end
