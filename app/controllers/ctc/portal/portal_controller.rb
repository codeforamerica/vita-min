class Ctc::Portal::PortalController < ApplicationController
  include AuthenticatedClientConcern
  layout "portal"

  def home

  end

  private

  def service_type
    :ctc
  end

  def wrapping_layout
    service_type
  end
end
