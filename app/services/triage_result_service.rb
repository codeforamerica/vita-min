class TriageResultService
  attr_reader :triage

  def initialize(triage)
    @triage = triage
  end

  def after_income_levels
    return route_to_diy if outside_gyr_filing_limit?
    return route_to_does_not_qualify if outside_diy_filing_limit?
  end

  def after_id_type
    route_no_income_clients
  end

  def after_doc_type
    if inside_express_income_limit?
      if triage.id_type_have_id?
        if triage.doc_type_need_help?
          Questions::TriageIncomeTypesController.to_path_helper
        end
      elsif triage.id_type_know_number?
        if has_some_tax_docs
          route_to_diy
        elsif triage.doc_type_need_help?
          Questions::TriageIncomeTypesController.to_path_helper
        end
      elsif triage.id_type_need_itin_help?
        Questions::TriageIncomeTypesController.to_path_helper
      end
    elsif inside_gyr_income_limit?
      if triage.id_type_have_id?
        if triage.doc_type_need_help?
          Questions::TriageIncomeTypesController.to_path_helper
        end
      elsif triage.id_type_know_number?
        route_to_diy
      elsif triage.id_type_need_itin_help?
        Questions::TriageIncomeTypesController.to_path_helper
      end
    end
  end

  def after_backtaxes_years
    if inside_express_income_limit?
      if triage.id_type_have_id?
        if has_some_tax_docs
          if any_missing_previous_year_filings
            Questions::TriageIncomeTypesController.to_path_helper
          elsif has_filed_all_years
            route_to_does_not_qualify
          end
        end
      end
    elsif inside_gyr_income_limit?
      if triage.id_type_have_id?
        if has_some_tax_docs
          if any_missing_previous_year_filings
            Questions::TriageIncomeTypesController.to_path_helper
          elsif has_filed_all_years
            route_to_does_not_qualify
          end
        end
      end
    end
  end

  def after_assistance
    if inside_express_income_limit?
      if triage.id_type_have_id?
        if has_some_tax_docs
          if has_not_filed_current_year_has_filed_all_previous_years
            if does_not_want_assistance?
              route_to_diy
            end
          end
        end
      end
    elsif inside_gyr_income_limit?
      if triage.id_type_have_id?
        if has_some_tax_docs
          if has_not_filed_current_year_has_filed_all_previous_years
            if does_not_want_assistance?
              route_to_diy
            end
          end
        end
      end
    end
  end

  def after_income_type
    if inside_express_income_limit?
      if triage.id_type_have_id?
        if has_some_tax_docs
          if any_missing_previous_year_filings
            branch_on_income_type_condition(route_to_gyr, route_to_diy)
          elsif has_not_filed_current_year_has_filed_all_previous_years
            if wants_assistance?
              branch_on_income_type_condition(route_to_gyr, route_to_diy)
            end
          end
        elsif triage.doc_type_need_help?
          branch_on_income_type_condition(route_to_express_gyr_choice, route_to_express)
        end
      elsif triage.id_type_know_number?
        if triage.doc_type_need_help?
          branch_on_income_type_condition(route_to_express_gyr_choice, route_to_express)
        end
      elsif triage.id_type_need_itin_help?
        branch_on_income_type_condition(route_to_gyr, route_to_express)
      end
    elsif inside_gyr_income_limit?
      if triage.id_type_have_id?
        if has_some_tax_docs
          if any_missing_previous_year_filings
            branch_on_income_type_condition(route_to_gyr, route_to_diy)
          elsif has_not_filed_current_year_has_filed_all_previous_years
            if wants_assistance?
              branch_on_income_type_condition(route_to_gyr, route_to_diy)
            end
          end
        elsif triage.doc_type_need_help?
          branch_on_income_type_condition(route_to_gyr, route_to_diy)
        end
      elsif triage.id_type_need_itin_help?
        if triage.income_level_25000_to_40000? || triage.income_level_40000_to_65000?
          branch_on_income_type_condition(route_to_gyr, route_to_does_not_qualify)
        else
          branch_on_income_type_condition(route_to_gyr, route_to_diy)
        end
      end
    end
  end

  private

  def route_no_income_clients
    if triage&.income_level_zero?
      if triage&.id_type_have_id?
        return route_to_express_gyr_choice
      elsif triage&.id_type_know_number?
        return route_to_diy
      elsif triage&.id_type_need_itin_help?
        return route_to_gyr
      end
    end
  end

  def inside_express_income_limit?
    triage.income_level_1_to_12500? ||
      (triage.filing_status_jointly? && triage.income_level_12500_to_25000?)
  end

  def inside_gyr_income_limit?
    (triage.filing_status_single? && triage.income_level_12500_to_25000?) ||
      (triage.income_level_25000_to_40000? || triage.income_level_40000_to_65000?)
  end

  def outside_diy_filing_limit?
    triage.income_level_over_73000?
  end

  def outside_gyr_filing_limit?
    triage.income_level_65000_to_73000?
  end

  def route_to_ctc
    Questions::TriageGyrExpressController.to_path_helper
  end

  def route_to_does_not_qualify
    Questions::TriageDoNotQualifyController.to_path_helper
  end

  def route_to_diy
    Questions::TriageReferralController.to_path_helper
  end

  def route_to_gyr
    Questions::TriageGyrController.to_path_helper
  end

  def route_to_express_gyr_choice
    Questions::TriageGyrExpressController.to_path_helper
  end

  def route_to_express
    Questions::TriageExpressController.to_path_helper
  end

  def branch_on_income_type_condition(eligible_path, ineligible_path)
    if triage.income_type_rent_yes? || triage.income_type_farm_yes?
      ineligible_path
    else
      eligible_path
    end
  end

  def route_to_gyr_if_qualified_diy_fallback
    if triage.income_type_rent_yes? || triage.income_type_farm_yes?
      return route_to_diy
    else
      return route_to_gyr
    end
  end

  def route_to_express_gyr_choice_if_qualified_express_fallback
    if triage.income_type_rent_yes? || triage.income_type_farm_yes?
      return route_to_express
    else
      return route_to_express_gyr_choice
    end
  end

  def route_to_gyr_if_qualified_express_fallback
    if triage.income_type_rent_yes? || triage.income_type_farm_yes?
      return route_to_express
    else
      return route_to_gyr
    end
  end

  def has_some_tax_docs
    %w[all_copies some_copies].include?(triage.doc_type)
  end

  def wants_assistance?
    [:assistance_in_person, :assistance_phone_review_english, :assistance_phone_review_non_english].any? { |m| triage.send(m) == "yes" }
  end

  def does_not_want_assistance?
    [:assistance_in_person, :assistance_phone_review_english, :assistance_phone_review_non_english].none? { |m| triage.send(m) == "yes" }
  end

  def any_missing_previous_year_filings
    [:filed_2018, :filed_2019, :filed_2020].any? { |m| triage.send(m) == "no" }
  end

  def has_not_filed_current_year_has_filed_all_previous_years
    !any_missing_previous_year_filings && triage.send("filed_#{TaxReturn.current_tax_year}") == "no"
  end

  def has_filed_all_years
    !any_missing_previous_year_filings && triage.send("filed_#{TaxReturn.current_tax_year}") == "yes"
  end
end
