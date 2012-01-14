module RailsPanel
  module ResourcesHelper

    def render_resources_menu
      return if @resources_menu.nil?
      html = '<ul class="pills">'
      @resources_menu.each do |title, path|
        html << "<li>" + link_to(title, path) + "</li>"
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
      current_model.table_attributes_keys
    end

    # Current model attributes. Use this method to customize form. By default it delegates
    def form_attributes
      current_model.form_attributes
    end

    # Current model attributes. Use this method to select or order fields in form. By default it delegates
    def form_attributes_keys
      current_model.form_attributes_keys
    end

    # Current model attributes. Use this method to display or reorder fields in show action. By default it delegates
    def show_attributes_keys
      current_model.show_attributes_keys
    end

    # Current model attributes. Use this method to customize attributes for all views in this controller. By default it delegates
    def show_attributes
      current_model.show_attributes
    end

    # Current model attributes. Use this method to customize attributes for all views in this controller. By default it delegates
    def attributes
      current_model.attributes
    end

    def current_model_params_key
      current_model.properties[:params_key]
    end

  end
end
