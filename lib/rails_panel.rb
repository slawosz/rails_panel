require "rails_panel/engine"
require "twitter-bootstrap-rails"

module RailsPanel
  mattr_accessor :controllers_without_model_mappings
  self.controllers_without_model_mappings = []
end
