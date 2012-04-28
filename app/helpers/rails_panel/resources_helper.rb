module RailsPanel
  module ResourcesHelper
    include LinkHelper
    include UrlHelper

    def render_resources_menu
      return if @resources_menu.nil?
      html = '<ul class="nav nav-pills">'
      @resources_menu.each do |title, path|
        css_class = (path == request.fullpath || request.fullpath[/(.*)\/.*/,1] == path) ? 'active' : ''
        html << "<li class='#{css_class}'>" + link_to(title, path) + "</li>"
      end
      html << "</ul>"
      html.html_safe
    end

    def form_field_for(form_instance, form_field, &block)
      html = '<div class="clearfix">'
      html << form_instance.label(form_field)
      html << '<div class="input">'
      html << capture(&block)
      html << '</div>'
      html.html_safe
    end

    def title(_title = controller.controller_name)
      content_for(:title) { _title.titleize }
    end

    def subtitle(_subtitle = controller.action_name)
      content_for(:subtitle) { _subtitle }
    end

    def table_attributes_keys
      model_representer.table_attributes_keys
    end

    # Current model attributes. Use this method to customize form. By default it delegates
    def form_attributes
      model_representer.form_attributes
    end

    # Current model attributes. Use this method to select or order fields in form. By default it delegates
    def form_attributes_keys
      model_representer.form_attributes_keys
    end

    # Current model attributes. Use this method to display or reorder fields in show action. By default it delegates
    def show_attributes_keys
      model_representer.show_attributes_keys
    end

    # Current model attributes. Use this method to customize attributes for all views in this controller. By default it delegates
    def show_attributes
      model_representer.show_attributes
    end

    # Current model attributes. Use this method to customize attributes for all views in this controller. By default it delegates
    def attributes
      model_representer.attributes
    end

    def model_representer_params_key
      model_representer.properties[:params_key]
    end

  end
end
