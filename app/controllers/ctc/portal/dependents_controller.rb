class Ctc::Portal::DependentsController < Ctc::Portal::BaseIntakeRevisionController

  def edit
    @form = form_class.from_dependent(current_model)
    render edit_template
  end

  def edit_template
    "ctc/portal/dependents/edit"
  end

  def confirm_remove; end

  def destroy
    current_model.update(soft_deleted_at: Time.current)
    SystemNote::CtcPortalAction.generate!(
      model: current_model,
      action: 'removed',
      client: current_client
    )

    redirect_to dependent_removal_summary_ctc_portal_dependents_path
  end

  private

  def current_model
    @_current_model ||= current_intake.dependents.find(params[:id])
  end
  helper_method :current_model

  def eligibility_without_dependent
    Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents - [current_model])
  end
  helper_method :eligibility_without_dependent

  def form_class
    Ctc::Portal::DependentForm
  end
end
