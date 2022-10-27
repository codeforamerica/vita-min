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

    benefits = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)
    no_eligible_ctc_dependents = current_intake.dependents.filter { |d| Efile::DependentEligibility::ChildTaxCredit.new(d, TaxReturn.current_tax_year).qualifies? }.length.zero?

    if no_eligible_ctc_dependents || (!benefits.claiming_and_qualified_for_eitc? && open_for_eitc_intake?)
      redirect_to not_eligible_ctc_portal_dependents_path
    else
      redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
    end
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
