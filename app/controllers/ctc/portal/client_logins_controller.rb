class Ctc::Portal::ClientLoginsController < Portal::ClientLoginsController
  helper_method :wrapping_layout
  before_action :redirect_ctc_in_offseason

  private

  def service_type
    :ctc
  end

  def wrapping_layout
    service_type
  end

  def redirect_ctc_in_offseason
    redirect_to root_path if Routes::CtcDomain.new.matches?(request) && !open_for_ctc_login?
  end
end

