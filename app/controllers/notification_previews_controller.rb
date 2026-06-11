class NotificationPreviewsController < ApplicationController
  before_action :authenticate_user!

  # POST /notification_previews
  # Renders a preview of a templated outreach notification using
  # operator-supplied subject, body, recipient name, and signature blocks.
  def create
    formatted = NotificationFormatter.new(notification_params).build
    render plain: formatted, content_type: "text/html"
  end

  private

  def notification_params
    params.permit(:subject, :body, :recipient_name, :signature)
  end
end
