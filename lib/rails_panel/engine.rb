module RailsPanel
  class Engine < Rails::Engine
    isolate_namespace RailsPanel

    # cannot change this settings because RailsPanel based on
    # overriding methods from RailsPanel::ResourceHelper in local helpers
    config.action_controller.include_all_helpers = false
  end
end
