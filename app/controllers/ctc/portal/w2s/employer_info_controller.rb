class Ctc::Portal::W2s::EmployerInfoController < Ctc::Portal::BaseIntakeRevisionController
  def edit
    @form = form_class.from_w2(current_model)
    render edit_template
  end

  private

  def edit_template
    "ctc/questions/w2s/employer_info/edit"
  end

  def form_class
    Ctc::W2s::EmployerInfoForm
  end

  def current_model
    @_current_model ||= current_intake.w2s.find(params[:id])
  end

  def next_path
    redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
  end
end
