module NavigationHelper
  def tab_navigation_link(text, path)
    # if we are on the current page set the selected class
    is_selected = locale_agnostic_current_path?(path) ? " is-selected" : ""
    # return the html
    link_to(text, path, class: "tab-bar__tab#{is_selected}")
  end

  private
  def locale_agnostic_current_path?(path)
    remove_leading_locale_from_path(path) == remove_leading_locale_from_path(request.path)
  end

  def remove_leading_locale_from_path(path)
    path = URI.parse(path).path
    current_locale_path = "/#{I18n.locale}"
    if path.start_with? current_locale_path
      path[current_locale_path.length..-1]
    else
      path
    end
  end
end