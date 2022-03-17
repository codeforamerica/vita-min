module TriageConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_show_client_sign_in_link
    before_action :redirect_if_matching_source_param
  end

  private

  def redirect_if_matching_source_param
    redirect_to_intake_after_triage if SourceParameter.source_skips_triage(session[:source])
  end

  def set_show_client_sign_in_link
    @show_client_sign_in_link = true
  end
end
