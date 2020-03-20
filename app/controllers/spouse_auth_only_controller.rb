class SpouseAuthOnlyController < ApplicationController
  layout "question"

  helper_method :section_title
  helper_method :illustration_path

  def show
    token = params[:token]
    if token
      intake = Intake.where(spouse_auth_token: params[:token]).first
    end
    if !token || !intake
      return redirect_to not_found_path
    end

    session[:intake_id] = intake.id
    session[:authenticate_spouse_only] = true
  end

  def not_found; end

  def spouse_auth_complete; end

  def section_title; end

  def illustration_path
    "spouse-identity.svg"
  end
end