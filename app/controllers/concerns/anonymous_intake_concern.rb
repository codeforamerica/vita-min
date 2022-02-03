module AnonymousIntakeConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_intake, :set_show_client_sign_in_link
  end

  private

  def redirect_if_duplicate_ctc_client
    redirect_to questions_returning_client_path if current_intake.has_duplicate?
  end

  def set_show_client_sign_in_link
    @show_client_sign_in_link = true
  end
end
