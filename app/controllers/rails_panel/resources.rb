require 'formtastic'
module RailsPanel
  module Resources
    extend ActiveSupport::Concern

    included do
      before_filter :set_current_model
      helper_method :current_model, :current_resource

      # url helpers
      helper_method :link_to_new, :link_to_edit, :link_to_index, :link_to_show, :url_for_create, :url_for_update
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
          redirect_to url_for_show(@resource)
        else
          render :action => :new
        end
      end

      def edit
        @resource = resource_for_edit
      end

      def update
        @resource = resource_for_update
        if update_resource(@resource)
          redirect_to url_for_show(@resource)
        else
          render :action => :new
        end
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
        _params = params[current_model.properties[:params_key]]
        current_model.new(_params)
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

      def link_to_index
        view_context.link_to 'Back to index', url_for_index
      end

      def url_for_index
        url_for(:controller => _controller_url)
      end

      def link_to_show(resource, anchor = '')
        view_context.link_to (anchor == '' ? resource._name : anchor), url_for_show(resource)
      end

      def url_for_show(resource)
        url_for(:controller => _controller_url, :action => 'show', :id => resource.id)
      end

      def link_to_new
        view_context.link_to "New", url_for_new
      end

      def url_for_new
        url_for(:controller => _controller_url, :action => "new")
      end

      def link_to_edit(resource)
        view_context.link_to 'Edit', url_for_edit(resource)
      end

      def url_for_edit(resource)
        url_for(:controller => _controller_url, :action => "edit", :id => resource.id)
      end

      def url_for_create
        view_context.url_for(:controller => _controller_url, :action => "create")
      end

      def url_for_update(resource)
        view_context.url_for(:controller => _controller_url, :action => "update")
      end

      private
      # I had problem with it in helper so I moved it here
      def _controller_url
        self.class.name.underscore.sub('_controller','')
      end
    end

  end
end
