require 'formtastic'
module RailsPanel
  module Resources
    extend ActiveSupport::Concern

    included do
      before_filter :set_current_model
      helper_method :current_model, :current_resource
      # hack to bring up resources helper before other applications helper
      # to make them posibility to overide its methods, but it may be better way
      # to do this
      _temp_helpers = self._helpers
      self._helpers = Module.new
      _temp_helpers.ancestors.reverse.each do |mod|
        if mod.to_s == 'ApplicationHelper'
          _helpers.module_eval { include ResourcesHelper }
        end
        self. _helpers.module_eval { include mod }
        p mod
      end
      p self._helpers.included_modules
      # load standard layout
      layout 'rails_panel/twitter_bootstrap'
    end

    module ClassMethods
      # override method, because rails don't support
      # view inheritance from modules
      def parent_prefixes
        super << ["rails_panel/resources"]
      end
    end

    module InstanceMethods
      def index
        @resources = resources
      end

      def show
        @resource = resource_for_show
      end

      def new
        @resource = resource_for_new
      end

      def create
        @resource = resource_for_create
        if @resource.save
          redirect_to @resource
        else
          render :action => :new
        end
      end

      def edit
        @resource = resource_for_edit
      end

      def update
        @resource = resource_for_update
        update_resource @resource
        redirect_to @resource
      end

      def destroy
        destroy_resource
        redirect_to :index
      end

      private

      def resources
        current_model.all
      end

      def resource_for_create
        current_model.create(params[current_model.properties[:params_key]])
      end

      def update_resource(resource)
        resource.update_attributes(params[current_model.properties[:params_key]])
      end

      def destroy_resource
      end

      def resource_for_new
        current_model.new
      end

      def resource_for_edit
        current_model.find(params[:id])
      end

      def resource_for_update
        current_model.find(params[:id])
      end

      def resource_for_show
        current_model.find(params[:id])
      end

      def resource_for_delete
        current_model.find(params[:id])
      end

      def set_current_model
        @current_model ||= model_mappings
      end

      def current_model
        @current_model
      end

      def current_resource
        @resource
      end

      def model_mappings
        return if RailsPanel.controllers_without_model_mappings.map(&:name).include? self.class.name
        self.class.controller_name.classify.singularize.constantize
      rescue
        raise "Can not find model for #{self.class.name}. Overide model_mappings method in this controller or exclude it from using rails_panel in initializers."
      end
    end

  end
end
