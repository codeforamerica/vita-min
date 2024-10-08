require 'will_paginate/view_helpers/action_view'

module WillPaginateHelper
  class WillPaginateJSLinkRenderer < WillPaginate::ActionView::LinkRenderer
    def prepare(collection, options, template)
      options[:params] ||= {}
      options[:params]['_'] = nil
      super(collection, options, template)
    end

    protected

    def url(page)
      @base_url_params ||= begin
                             url_params = merge_get_params(default_url_params)
                             url_params[:only_path] = true
                             url_params[:action] = @options[:action]
                             merge_optional_params(url_params)
                           end

      url_params = @base_url_params.dup
      add_current_page_param(url_params, page)

      @template.url_for(url_params)
    end

    def link(text, target, attributes = {})
      if target.is_a? Integer
        attributes[:rel] = rel_value(target)
        target = url(target)
      end

      @template.link_to(target, attributes.merge(remote: true)) do
        text.to_s.html_safe
      end
    end
  end

  def js_will_paginate(collection, options = {})
    will_paginate(collection, options.merge(:renderer => WillPaginateHelper::WillPaginateJSLinkRenderer))
  end
end