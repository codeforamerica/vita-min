class TriageResultService
  SIMPLE_FILE_INCOME_LIMITS = {
    "CO" => {
      "single" => 15_000,
      "jointly" => 25_000
    },
    "NJ" => {
      "single" => 10_000,
      "jointly" => 20_000
    }
  }.freeze

  attr_reader :intake

  def initialize(intake)
    @intake = intake
  end

  def after_eligibility_household_triaged_route
    if recommend_simple_file?
      route_to_simple_file
    else
      after_income_levels_triaged_route
    end
  end

  def after_income_levels_triaged_route
    if intake.triage_income_level_zero? && intake.service_preference_diy?
      route_to_diy
    elsif intake.triage_income_level_1_to_69000? || intake.triage_income_level_69001_to_89000?
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
    simple_file_eligible? && simple_file_preferred?
  end

  def simple_file_eligible?
      within_simple_file_income_limit? &&
      qualifying_child? &&
      simple_file_income_types_only?
  end

  def simple_file_preferred?
    intake.triage_income_level_zero? &&
      no_disqualifying_income_situations? &&
      intake.has_access_to_income_documents_no? # They said "no" to having access to their income documents
  end

  def within_simple_file_income_limit?
    return true unless SIMPLE_FILE_INCOME_LIMITS.key?(intake.state_of_residence)

    income_limit = SIMPLE_FILE_INCOME_LIMITS.dig(intake.state_of_residence, intake.triage_filing_status)

    income_limit.present? && !intake.triage_income_level_above?(income_limit) #make this method
  end

  def qualifying_child?
    case intake.state_of_residence
    when "CO", "NJ"
      intake.had_qualifying_child_under_6_yes?
    else
      intake.had_qualifying_child_under_17_yes?
    end
  end

  def simple_file_income_types_only?
    no_disqualifying_income_situations?
  end

  def no_disqualifying_income_situations?
    intake.income_situations_none?
  end

  def route_to_does_not_qualify
    Questions::TriageDoNotQualifyController.to_path_helper
  end

  def route_to_simple_file
    Questions::TriageSimpleFileController.to_path_helper
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
end