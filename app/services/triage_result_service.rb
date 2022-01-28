class TriageResultService
  attr_reader :triage

  def initialize(triage)
    @triage = triage
  end

  def after_income_levels
    case triage&.income_level
    when "40000_to_65000"
      return route_to_diy
    when "65000_to_73000"
      return route_to_diy
    when "over_73000"
      return route_to_does_not_qualify
    else
      return route_to_full_service
    end
  end

  def after_backtaxes_years
    return

    # if triage.income_level_zero? && triage.filed_2020_yes? && triage.filed_2021_no?
    #   return route_to_ctc
    # end

    # # The presence of missing previous year filings may mean DIY isn't appropriate because it charges
    # # clients for years other than the current tax year. Plus GetCTC doesn't work for previous tax years.
    # # That leaves just full service/VITA.
    # if any_missing_previous_year_filings && has_some_tax_docs && triage.id_type_have_id??
    #   return Questions::TriageGyrController.to_path_helper
    # end
  end

  def after_assistance
    return

    # if triage.assistance_none_yes?
    #   return route_to_diy
    # end
  end

  def after_id_type
    return

    # return Questions::TriageIncomeTypesController.to_path_helper if triage.id_type_need_help?
  end

  def after_doc_type
    return

    # return route_to_ctc if
    #   (triage.income_level_zero? || triage.income_level_hh_1_to_25100?) &&
    #   (triage.id_type_have_id? || triage.id_type_know_number?) &&
    #   (triage.doc_type_need_help? || triage.doc_type_does_not_apply?)
    # return Questions::TriageIncomeTypesController.to_path_helper if triage.doc_type_need_help?
  end

  def after_income_type
    return

    # return route_to_diy if triage.income_type_farm_yes? || triage.income_type_rent_yes?
    # return route_to_ctc if (triage.income_level_zero? || triage.income_level_hh_1_to_25100?) &&
    #   (triage.id_type_have_id? || triage.id_type_know_number?) &&
    #   (triage.doc_type_need_help? || triage.doc_type_does_not_apply?)
    # return Questions::TriageGyrController.to_path_helper
  end

  private

  def route_to_ctc
    Questions::TriageExpressController.to_path_helper
  end

  def route_to_does_not_qualify
    Questions::TriageDoNotQualifyController.to_path_helper
  end

  def route_to_diy
    Questions::TriageReferralController.to_path_helper
  end

  def route_to_full_service
    Questions::TriageGyrController.to_path_helper
  end

  def has_some_tax_docs
    %w[all_copies some_copies does_not_apply].include?(triage.doc_type)
  end

  def any_missing_previous_year_filings
    [:filed_2018, :filed_2019, :filed_2020].any? { |m| triage.send(m) == "no" }
  end
end
