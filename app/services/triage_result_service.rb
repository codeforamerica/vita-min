class TriageResultService
  attr_reader :triage

  def initialize(triage)
    @triage = triage
  end

  def after_income_levels
    case triage&.income_level
    when "hh_66000_to_73000"
      return route_to_full_service
    when "hh_over_73000"
      return route_to_does_not_qualify
    end
  end

  def after_backtaxes_years
    # The presence of missing previous year filings may mean DIY isn't appropriate because it charges
    # clients for years other than the current tax year. Plus GetCTC doesn't work for previous tax years.
    # That leaves just full service/VITA.
    if any_missing_previous_year_filings && has_some_tax_docs && triage.id_type_have_paperwork?
      return route_to_full_service
    end
  end

  def after_assistance
    if triage.assistance_none_yes?
      return route_to_diy
    end
  end

  def after_doc_type
    return route_to_full_service if triage.doc_type_need_help?
  end

  def after_income_type
    return route_to_diy if triage.income_type_farm_yes? || triage.income_type_rent_yes?
    return Questions::TriageDeluxeController.to_path_helper
  end

  private

  def route_to_full_service
    Questions::TriageIncomeTypesController.to_path_helper
  end

  def route_to_does_not_qualify
    Questions::TriageDoNotQualifyController.to_path_helper
  end

  def route_to_diy
    Questions::TriageReferralController.to_path_helper
  end

  def has_some_tax_docs
    %w[all_copies some_copies does_not_apply].include?(triage.doc_type)
  end

  def any_missing_previous_year_filings
    [:filed_2018, :filed_2019, :filed_2020].any? { |m| triage.send(m) == "no" }
  end
end
