require 'rails/generators/rails/scaffold/scaffold_generator'
require_relative '../controller/controller_generator'
require_relative '../model/model_generator'

module RailsPanel
  class ScaffoldGenerator < Rails::Generators::ScaffoldGenerator
    source_root File.expand_path('../templates', __FILE__)
    remove_hook_for :controller_resource
    remove_hook_for :scaffold_controller
    remove_hook_for :stylesheet_engine
    remove_hook_for :test_framework
    remove_hook_for :orm

    def create_model_and_controller
      invoke RailsPanel::ModelGenerator
      invoke RailsPanel::ControllerGenerator
      puts %{
Remember to include RailsPanel::Resource in your controller or your controller superclass (ie. ApplicationController).
      }
    end
  end
end
