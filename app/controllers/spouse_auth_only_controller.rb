class SpouseAuthOnlyController < ApplicationController
  layout "question"

  helper_method :illustration_path

  def show
    intake = Intake.where.not(spouse_auth_token: nil).where(spouse_auth_token: params[:token]).first
    return redirect_to verify_spouse_not_found_path unless intake.present?

    session[:intake_id] = intake.id
    session[:authenticate_spouse_only] = true
  end

  def not_found; end

  def spouse_auth_complete; end

  def illustration_path
    "spouse-identity.svg"
  end
end