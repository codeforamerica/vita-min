module Portal
  class PortalController < ApplicationController
    before_action :require_client_sign_in
    layout "question"

    helper_method :illustration_path

    def illustration_path; end

    def home; end

    private

    def require_client_sign_in
      redirect_to root_path unless current_client.present?
    end
  end
end
