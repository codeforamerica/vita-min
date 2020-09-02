class CasesController < ApplicationController
  include ZendeskAuthenticationControllerHelper

  before_action :require_zendesk_admin

  layout "admin"

  def create
    intake = Intake.find_by(id: params[:intake_id])
    return head 422 unless intake.present?

    created_case = Case.create_from_intake(intake)
    redirect_to case_path(id: created_case.id)
  end

  def show
    @case = Case.find(params[:id])
  end
end