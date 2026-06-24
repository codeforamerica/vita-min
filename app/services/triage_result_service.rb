class TriageResultService
  attr_reader :intake

  def initialize(intake)
    @intake = intake
  end

  def after_household_triaged_route
    return route_to_simple_file if recommend_simple_file?

    if intake.triage_income_level_zero? && intake.service_preference_diy?
      route_to_diy
    elsif income_level_from_1_to_69000? || intake.triage_income_level_69001_to_89000?
      if intake.triage_vita_income_ineligible_yes? || intake.service_preference_diy?
        route_to_diy
      else
        route_to_gyr
      end
    elsif intake.triage_income_level_over_89000? && intake.triage_vita_income_ineligible_yes?
      route_to_offboarding
    else
      route_to_gyr
    end
  end

  private

  def recommend_simple_file?
    simple_file_eligible? && simple_file_priority_condition?
  end

  def simple_file_eligible?
    simple_file_state_eligible? && simple_file_income_eligible? &&
      simple_file_income_types_eligible? && simple_file_qualifying_child_eligible?
  end

  def simple_file_state_eligible?
    intake.state_of_residence.in?(%w[CO NJ])
  end

  def simple_file_income_eligible?
    eligible_income_levels =
      case [intake.state_of_residence, intake.triage_filing_status]
      when ["CO", "single"]
        %w[
          zero
          1_to_10000
          10001_to_15000
        ]
      when ["CO", "jointly"]
        %w[
          zero
          1_to_10000
          10001_to_15000
          15001_to_20000
        ]
      when ["NJ", "single"]
        %w[
          zero
          1_to_10000
        ]
      when ["NJ", "jointly"]
        %w[
          zero
          1_to_10000
          10001_to_15000
          15001_to_20000
        ]
      else
        []
      end

    intake.triage_income_level.in?(eligible_income_levels)
  end

  def simple_file_income_types_eligible?
    !intake.had_self_employment_income_yes? &&
      !intake.multiple_states_yes? &&
      !intake.had_rental_income_yes? &&
      !intake.had_farm_income_yes? &&
      !intake.has_crypto_income?
  end

  def simple_file_qualifying_child_eligible?
    case intake.state_of_residence
    when "CO"
      intake.had_qualifying_child_under_17_yes?
    when "NJ"
      intake.had_qualifying_child_under_6_yes?
    else
      false
    end
  end

  def simple_file_priority_condition?
    intake.triage_income_level_zero? ||
      intake.triage_vita_income_ineligible_yes? ||
      intake.have_income_tax_documents_no?
  end

  def income_level_from_1_to_69000?
    intake.triage_income_level.in?(
      %w[
        1_to_10000
        10001_to_15000
        15001_to_20000
        20001_to_26000
        26001_to_69000
        1_to_69000
      ]
    )
  end

  def route_to_does_not_qualify
    Questions::TriageDoNotQualifyController.to_path_helper
  end

  def route_to_diy
    Questions::TriageDiyController.to_path_helper
  end

  def route_to_gyr
    Questions::TriageGyrController.to_path_helper
  end

  def route_to_gyr_diy_choice
    Questions::TriageGyrDiyController.to_path_helper
  end

  def route_to_offboarding
    Questions::TriageOffboardingController.to_path_helper
  end

  def route_to_simple_file
    SimpleFileUrlService.new(intake: intake, locale: intake.locale, source: "gyrsel").url
  end
end