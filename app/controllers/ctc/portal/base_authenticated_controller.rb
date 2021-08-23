class Ctc::Portal::BaseAuthenticatedController < ApplicationController
  include AuthenticatedClientConcern
  layout "portal"

  private

  def service_type
    :ctc
  end

  def wrapping_layout
    service_type
  end
end
