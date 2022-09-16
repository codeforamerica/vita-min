class Ctc::Portal::W2s::EmployerInfoController < Ctc::Portal::BaseIntakeRevisionController
  before_action :set_continue_label

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
    Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
  end

  def set_continue_label
    # using presence of required field to ascertain whether this is a new W-2
    if current_model.employer_name.present?
      @continue_label = t("views.ctc.portal.w2s.employer_info.update_w2")
    else
      @continue_label = t("views.ctc.questions.w2s.employer_info.add")
    end
  end
end
