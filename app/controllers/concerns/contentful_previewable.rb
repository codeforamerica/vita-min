module ContentfulPreviewable
  extend ActiveSupport::Concern

  included do
    helper_method :preview_mode? # optional for views
  end

  def preview_mode?
    # determines if request should preview
    return true if params[:preview_token] == Rails.application.credentials.dig(:contentful, :preview_access_token)

    false
  end
end