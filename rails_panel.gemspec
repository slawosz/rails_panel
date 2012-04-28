$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_panel/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_panel"
  s.version     = RailsPanel::VERSION
  s.authors     = ["Sławosz Sławiński"]
  s.email       = ["slawosz@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of RailsPanel."
  s.description = "TODO: Description of RailsPanel."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.1"
  s.add_dependency "formtastic"
  s.add_dependency "formtastic-bootstrap"
  s.add_dependency "kaminari"
  s.add_dependency "twitter-bootstrap-rails"
  s.add_dependency "libv8"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
