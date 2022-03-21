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
    ctc_eligibility = Efile::DependentEligibility::ChildTaxCredit
    if current_intake.dependents.filter { |d| ctc_eligibility.new(d, TaxReturn.current_tax_year).qualifies? }.length.zero?
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

  def form_class
    Ctc::Portal::DependentForm
  end
end
