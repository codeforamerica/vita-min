class Ctc::Portal::W2s::WagesInfoController < Ctc::Portal::BaseIntakeRevisionController
  def edit
    @form = form_class.from_w2(current_model)
    render edit_template
  end

  private

  def edit_template
    "ctc/questions/w2s/wages_info/edit"
  end

  def form_class
    Ctc::W2s::WagesInfoForm
  end

  def next_path
    Ctc::Portal::W2s::EmployerInfoController.to_path_helper(action: :edit, id: current_model.id)
  end

  def current_model
    @_current_model ||= current_intake.w2s.find(params[:id])
  end
end
