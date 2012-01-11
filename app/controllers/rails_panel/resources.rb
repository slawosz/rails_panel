require 'formtastic'
module RailsPanel
  module Resources
    extend ActiveSupport::Concern

    included do
      before_filter :set_current_model
      helper_method :current_model, :current_resource, :current_resources

      respond_to :html

      # url helpers
      helper_method :link_to_new, :link_to_edit, :link_to_index, :link_to_show, :link_to_destroy, :url_for_create, :url_for_update
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

      def set_current_model
        @current_model ||= model_mappings
      end

      def current_model
        @current_model
      end

      def current_resource
        @resource
      end

      def current_resources
        @resources
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

      def link_to_destroy(resource)
        view_context.link_to 'Destroy', url_for_destroy(resource), :confirm => 'Are you sure?', :method => :delete
      end

      def url_for_destroy(resource)
        url_for(:controller => _controller_url, :action => "destroy", :id => resource.id)
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

      def notice_for(resource, action, result = :success)
        "#{resource._name}, action #{action}"
      end
    end

  end
end
