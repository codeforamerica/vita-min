module ControllerHelpers
  extend ActiveSupport::Concern

  def response_html
    @response_html ||= Nokogiri::HTML.parse(response.body)
  end
end
