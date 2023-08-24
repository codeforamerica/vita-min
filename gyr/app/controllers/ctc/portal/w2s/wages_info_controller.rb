class Ctc::Portal::W2s::WagesInfoController < Ctc::Portal::W2s::BaseController
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
    if current_intake.benefits_eligibility.disqualified_for_simplified_filing?
      Ctc::Questions::UseGyrController.to_path_helper
    else
      Ctc::Portal::W2s::EmployerInfoController.to_path_helper(action: :edit, id: current_model.id)
    end
  end

  def current_model
    @_current_model ||= current_intake.w2s_including_incomplete.find(params[:id])
  end
end
