module FirstQuestionConcern
  def current_intake
    Intake::CtcIntake.new(visitor_id: cookies[:visitor_id])
  end

  def after_update_success
    session[:intake_id] = @form.intake.id
  end
end
