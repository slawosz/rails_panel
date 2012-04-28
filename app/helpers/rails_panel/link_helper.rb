module RailsPanel
  module LinkHelper
    def link_to_index
      link_to desc('Back to index','list'), url_for_index, :class => classes
    end

    def link_to_show(resource, anchor = '')
      link_to (anchor == '' ? resource._name : anchor), url_for_show(resource)
    end

    def link_to_new
      link_to desc('Add new','plus'), url_for_new, :class => classes
    end

    def link_to_edit(resource)
      link_to desc('Edit resource','pencil'), url_for_edit(resource), :class => classes
    end

    def link_to_destroy(resource)
      link_to desc('Destroy resource','exclamation-sign'),
        url_for_destroy(resource),
        :confirm => 'Are you sure?',
        :method => :delete,
        :class => 'btn btn-danger'
    end

    def desc(label, icon_name)
      "#{icon(icon_name)} #{label}".html_safe
    end

    def icon(name)
      "<i class='icon-#{name} icon-white'></i>"
    end

    def classes
      'btn btn-primary'
    end
  end
end
