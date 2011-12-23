module RailsPanel
  module Resources
    extend ActiveSupport::Concern

    included do
      before_filter :set_current_model
      helper_method :current_model
      helper_method :current_resource
      helper 'rails_panel/resources'
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
        @resource = create_resource
        redirect_to @resource
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

      def create_resource
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
        self.class.controller_name.singularize.capitalize.constantize
      end
    end

  end
end
