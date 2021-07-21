module FirstQuestionConcern
  extend ActiveSupport::Concern
  included do
    after_action :set_intake_to_session, only: :update
  end

  def current_intake
    Intake::CtcIntake.new(visitor_id: cookies[:visitor_id], source: session[:source])
  end

  def set_intake_to_session
    session[:intake_id] = @form.intake.id if @form.intake.persisted?
  end
end
