class Ctc::Update::SpousePriorTaxYearAgiController < Ctc::Update::BaseIntakeRevisionController
  private

  def edit_template
    "ctc/portal/spouse_prior_tax_year_agi/edit"
  end

  def form_class
    Ctc::SpousePriorTaxYearAgiForm
  end
end
