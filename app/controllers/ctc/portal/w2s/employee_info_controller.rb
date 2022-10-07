class Ctc::Portal::W2s::EmployeeInfoController < Ctc::Portal::BaseIntakeRevisionController
  def edit
    @form = form_class.from_w2(current_model)
    render edit_template
  end

  private

  def generate_system_note
    if @new_record
      SystemNote::CtcPortalAction.generate!(
        model: current_model,
        action: 'created',
        client: current_client
      )
    else
      SystemNote::CtcPortalUpdate.generate!(
        model: current_model,
        client: current_client,
      )
    end
  end

  def edit_template
    "ctc/questions/w2s/employee_info/edit"
  end

  def form_class
    Ctc::W2s::EmployeeInfoForm
  end

  def current_model
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    token = verifier.verified(params[:id])
    @_current_model ||=
      if token
        @new_record = true
        current_intake.w2s_including_incomplete.find_or_initialize_by(creation_token: token)
      else
        current_intake.w2s_including_incomplete.find(params[:id])
      end
  end

  def next_path
    Ctc::Portal::W2s::WagesInfoController.to_path_helper(action: :edit, id: current_model.id)
  end
end
