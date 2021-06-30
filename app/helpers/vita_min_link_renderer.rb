require 'will_paginate/view_helpers/action_view'

class VitaMinLinkRenderer < WillPaginate::ActionView::LinkRenderer
  def html_container(html)
    tag(:nav, html, container_attributes)
  end
end
