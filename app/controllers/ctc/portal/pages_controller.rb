class Ctc::Portal::PagesController < Ctc::Portal::BaseAuthenticatedController
  def no_eligible_dependents
    no_eligible_ctc_dependents = current_intake.dependents.filter { |d| Efile::DependentEligibility::ChildTaxCredit.new(d, TaxReturn.current_tax_year).qualifies? }.length.zero?
    benefits = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)

    @ineligible_credits = if no_eligible_ctc_dependents && (!benefits.claiming_and_qualified_for_eitc? && open_for_eitc_intake?)
                            I18n.t("views.ctc.portal.dependents.no_eligible_dependents.credits")
                          elsif no_eligible_ctc_dependents
                            "CTC"
                          else
                            "EITC"
                          end
  end
end