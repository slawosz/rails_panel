require 'rails/generators/active_record/model/model_generator'

module RailsPanel
  class ModelGenerator < ActiveRecord::Generators::ModelGenerator

    source_root File.expand_path('../templates', __FILE__)
  end
end
