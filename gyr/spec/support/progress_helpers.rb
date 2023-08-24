def track_progress
  html_body = Nokogiri::HTML.parse(page.body)
  @current_progress = html_body.at_css(".progress-indicator__bar")["style"].tr("width:%", "").to_i
end