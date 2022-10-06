class Ctc::Portal::W2s::MiscInfoController < Ctc::Portal::BaseIntakeRevisionController
  before_action :set_continue_label

  def edit
    @form = form_class.from_w2(current_model)
    render edit_template
  end

  private

  def edit_template
    "ctc/questions/w2s/misc_info/edit"
  end

  def form_class
    Ctc::W2s::MiscInfoForm
  end

  def current_model
    @_current_model ||= current_intake.w2s_including_incomplete.find(params[:id])
  end

  def set_continue_label
    if current_model.completed_at.present?
      @continue_label = t("views.ctc.portal.w2s.employer_info.update_w2")
    else
      @continue_label = t("views.ctc.questions.w2s.employer_info.add")
    end
  end
end
