class Ctc::Portal::PriorTaxYearAgiController < Ctc::Portal::BaseIntakeRevisionController
  private

  def edit_template
    "ctc/portal/prior_tax_year_agi/edit"
  end

  def form_class
    Ctc::PriorTaxYearAgiForm
  end
end
