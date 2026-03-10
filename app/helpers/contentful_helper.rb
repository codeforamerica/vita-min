module ContentfulHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, link_attributes: { target: "_blank" })
    Redcarpet::Markdown.new(renderer, autolink: true, tables: true).render(text).html_safe
  end
end