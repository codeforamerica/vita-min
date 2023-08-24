module AnonymousIntakeConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_intake, :set_show_client_sign_in_link
  end

  private

  def set_show_client_sign_in_link
    @show_client_sign_in_link = true
  end
end
