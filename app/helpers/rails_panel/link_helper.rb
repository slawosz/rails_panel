module RailsPanel
  module LinkHelper
    def link_to_index
      link_to 'Back to index', url_for_index
    end

    def link_to_show(resource, anchor = '')
      link_to (anchor == '' ? resource._name : anchor), url_for_show(resource)
    end

    def link_to_new
      link_to "New", url_for_new
    end

    def link_to_edit(resource)
      link_to 'Edit', url_for_edit(resource)
    end

    def link_to_destroy(resource)
      link_to 'Destroy', url_for_destroy(resource), :confirm => 'Are you sure?', :method => :delete
    end
  end
end
