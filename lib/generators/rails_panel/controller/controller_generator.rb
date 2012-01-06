require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
require 'rails/generators/resource_helpers'

module RailsPanel
  class ControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
    include Rails::Generators::ResourceHelpers
    source_root File.expand_path('../templates', __FILE__)


    def create_root_folder
      empty_directory File.join("app/views", controller_file_path)
    end

    remove_hook_for :template_engine
    remove_hook_for :scaffold_controller
    hook_for :assets, :in => :rails
  end

end
