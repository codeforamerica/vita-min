class Ctc::Portal::W2s::EmployeeInfoController < Ctc::Portal::BaseIntakeRevisionController
  def edit
    @form = form_class.from_w2(current_model)
    @form.employee_ssn_confirmation = current_model.employee_ssn if current_model.employee_ssn.present?
    render edit_template
  end

  def update
    puts "yay im updatin"
    puts params.to_json
    val = super
    puts "returning #{val.inspect}"
    val
  end

  private

  def edit_template
    "ctc/portal/w2s/employee_info/edit"
  end

  def form_class
    Ctc::W2s::EmployeeInfoForm
  end

  def current_model
    @_current_model ||= current_intake.w2s.find(params[:id])
  end

  def next_path
    redirect_to Ctc::Portal::W2s::EmployerInfoController.to_path_helper(action: :edit, id: current_model.id)
  end
end
