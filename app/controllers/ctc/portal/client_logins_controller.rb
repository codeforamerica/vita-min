class Ctc::Portal::ClientLoginsController < Portal::ClientLoginsController
  helper_method :wrapping_layout

  private

  def service_type
    :ctc
  end

  def wrapping_layout
    service_type
  end
end

