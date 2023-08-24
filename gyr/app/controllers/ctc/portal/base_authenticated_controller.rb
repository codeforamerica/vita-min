class Ctc::Portal::BaseAuthenticatedController < ApplicationController
  include AuthenticatedClientConcern
  layout "portal"
  before_action :redirect_if_read_only

  private

  def service_type
    :ctc
  end

  def wrapping_layout
    service_type
  end

  def redirect_if_read_only
    return if open_for_ctc_read_write?

    redirect_back(fallback_location: Ctc::Portal::PortalController.to_path_helper(action: :home))
  end
end
