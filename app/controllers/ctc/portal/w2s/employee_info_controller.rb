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
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    token = verifier.verified(params[:id])
    if token
      @new_model = true
      current_intake.w2s.find_or_initialize_by(creation_token: token)
    else
      current_intake.w2s.find(params[:id])
    end
  end

  def next_path
    redirect_to Ctc::Portal::W2s::EmployerInfoController.to_path_helper(action: :edit, id: current_model.id)
  end

  def create_system_note
    SystemNote::CtcPortalUpdate.generate!(
      model: current_model,
      client: current_client,
      new: @new_model
    )
  end
end
