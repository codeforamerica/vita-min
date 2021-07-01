class VitaMinLinkRenderer < WillPaginate::ActionView::LinkRenderer
  def html_container(html)
    tag(:nav, html, container_attributes)
  end
end