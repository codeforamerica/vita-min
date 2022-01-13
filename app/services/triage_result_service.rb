class TriageResultService
  attr_reader :triage

  def initialize(triage)
    @triage = triage
  end

  def after_income_levels
    case triage&.income_level
    when "hh_66000_to_73000"
      return Questions::TriageReferralController.to_path_helper
    when "hh_over_73000"
      return Questions::TriageDoNotQualifyController.to_path_helper
    end

  end

  def after_backtaxes_years
    if no_previous_year_filings && has_some_tax_docs && triage.id_type_have_paperwork?
      return Questions::TriageIncomeTypesController.to_path_helper
    end
  end

  def after_income_type

  end

  private

  def has_some_tax_docs
    %w[all_copies some_copies].include?(triage.doc_type)
  end

  def no_previous_year_filings
    [:filed_2018, :filed_2019, :filed_2020].any? { |m| triage.send(m) == "no" }
  end
end
