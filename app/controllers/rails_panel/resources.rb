require 'formtastic'
module RailsPanel
  # Include this module to rails controller, and it will display panel for related model out of the box!
  #
  # By default controller that includes this model has all CRUD actions:
  # * index
  # * show
  # * new
  # * create
  # * edit
  # * update
  # * destroy
  #
  # All actions has corresponding views.
  #
  # But it is still normal RailsController, so:
  # * any action can be override
  # * any view can be override - see below
  #
  # You can also override some methods, for feching model data for controller.
  # TODO: extract data methods to another module
  # For these methods see,
  #
  #
  # TODO
  # Provided views:
  # *
  #
  #
  # To change model used in this controller, override method set_current_model
  module Resources
    extend ActiveSupport::Concern

    included do
      before_filter :set_current_model
      helper_method :current_model, :current_resource, :current_resources
      helper_method :_controller_url

      respond_to :html

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
        respond_with @resources
      end

      def show
        @resource = resource_for_show
        respond_with @resource
      end

      def new
        @resource = resource_for_new
      end

      def create
        @resource = resource_for_create
        if @resource.save
          redirect_to url_for_show(@resource), :notice => notice_for(@resource, :create)
        else
          flash[:alert] = notice_for(@resource, :create, :failure)
          render :action => :new
        end
      end

      def edit
        @resource = resource_for_edit
      end

      def update
        @resource = resource_for_update
        if update_resource(@resource)
          redirect_to url_for_show(@resource), :notice => notice_for(@resource, :update)
        else
          flash[:alert] = notice_for(@resource, :update, :failure)
          render :action => :edit
        end
      end

      def destroy
        destroy_resource
        if current_resource.destroyed?
          flash[:notice] = notice_for(current_resource, :destroyed)
        else
          flash[:alert] = notice_for(current_resource, :destroyed, :failure)
        end

        redirect_to url_for_index
      end

      private

      # Used in index
      def resources
        current_model.page params[:page]
      end

      def resource_for_create
        _params = params[current_model.properties[:params_key]]
        current_model.new(_params)
      end

      def update_resource(resource)
        resource.update_attributes(params[current_model.properties[:params_key]])
      end

      def destroy_resource
        resource_for_destroy.destroy
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

      def resource_for_destroy
        @resource = current_model.find(params[:id])
      end

      # Use this method to change model for this controller
      def set_current_model
        @current_model ||= model_mappings
      end

      # Model used in this controller
      def current_model
        @current_model
      end

      # Current model instance
      def current_resource
        @resource
      end

      # Current model instances collection
      def current_resources
        @resources
      end

      # Return model which will be used for current controller
      def model_mappings
        return if RailsPanel.controllers_without_model_mappings.map(&:name).include? self.class.name
        self.class.controller_name.classify.singularize.constantize
      rescue
        raise "Can not find model for #{self.class.name}. Overide model_mappings method in this controller or exclude it from using rails_panel in initializers."
      end

      private
      # current controller url
      def _controller_url
        self.class.name.underscore.sub('_controller','')
      end

      # Method that displays flash notices.
      def notice_for(resource, action, result = :success)
        "#{resource._name}, action #{action}"
      end
    end

  end
end
