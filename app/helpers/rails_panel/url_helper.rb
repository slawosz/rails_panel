module RailsPanel
  module UrlHelper
    def url_for_index
      url_for(:controller => _controller_url)
    end

    def url_for_show(resource)
      url_for(:controller => _controller_url, :action => 'show', :id => resource.id)
    end

    def url_for_edit(resource)
      url_for(:controller => _controller_url, :action => "edit", :id => resource.id)
    end

    def url_for_new
      url_for(:controller => _controller_url, :action => "new")
    end

    def url_for_destroy(resource)
      url_for(:controller => _controller_url, :action => "destroy", :id => resource.id)
    end

    def url_for_create
      url_for(:controller => _controller_url, :action => "create")
    end

    def url_for_update(resource)
      url_for(:controller => _controller_url, :action => "update")
    end
  end
end
