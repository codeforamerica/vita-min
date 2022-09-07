class Ctc::Portal::W2s::EmployeeInfoController < Ctc::Portal::BaseIntakeRevisionController
  def edit
    @form = form_class.from_w2(current_model)
    render edit_template
  end

  private

  def edit_template
    "ctc/questions/w2s/employee_info/edit"
  end

  def form_class
    Ctc::W2s::EmployeeInfoForm
  end

  def current_model
    @_current_model ||= current_intake.w2s.find(params[:id])
  end
  # helper_method :current_model
end
