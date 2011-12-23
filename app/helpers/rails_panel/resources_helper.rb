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

    def table_attributes_keys
      current_model.table_attributes_keys
    end

    def form_attributes
      current_model.form_attributes
    end

    def form_attributes_keys
      current_model.form_attributes_keys
    end

    def show_attributes_keys
      current_model.show_attributes_keys
    end

    def show_attributes
      current_model.show_attributes
    end

    def attributes
      current_model.attributes
    end

    def current_model_params_key
      current_model.properties[:params_key]
    end

    def link_to_index
      link_to 'Back to index', url_for(current_model.name.pluralize.downcase.to_sym)
    end

    def link_to_edit
      link_to 'Edit', url_for([:edit, current_resource])
    end

    def link_to_new
      link_to "New", url_for([:new, current_model.name.downcase.to_sym])
    end
  end
end
