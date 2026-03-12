module ContentfulPreviewable
  extend ActiveSupport::Concern

  included do
    before_action :set_contentful_preview
  end

  private

  def set_contentful_preview
    @contentful_preview = params[:contentful_preview] == 'true' && current_user&.admin?
  end
end