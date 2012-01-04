require "rails_panel/engine"

module RailsPanel
  mattr_accessor :controllers_without_model_mappings
  self.controllers_without_model_mappings = []
end
