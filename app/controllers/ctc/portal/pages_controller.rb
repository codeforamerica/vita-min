class Ctc::Portal::PagesController < Ctc::Portal::BaseAuthenticatedController
  def dependent_removal_summary
    benefits = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)
    eitc_warning = current_intake.claim_eitc_yes? && !benefits.claiming_and_qualified_for_eitc?
    ctc_warning = !benefits.any_eligible_ctc_dependents?

    @credit_warnings = if ctc_warning && eitc_warning
                         I18n.t("views.ctc.portal.dependents.dependent_removal_summary.ctc_and_eitc")
                       elsif ctc_warning
                         "CTC"
                       elsif eitc_warning
                         "EITC"
                       else
                         nil
                       end

    if @credit_warnings.nil?
      redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
    end
  end
end