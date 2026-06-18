class TriageResultService
  attr_reader :intake

  def initialize(intake)
    @intake = intake
  end

  def income_level_from_1_to_69000?(intake)
    ["1_to_10000",
     "10001_to_15000",
     "15001_to_20000",
     "20001_to_26000",
     "26001_to_69000",
     "1_to_69000"].include? intake.triage_income_level
  end

  def after_income_levels_triaged_route
    if intake.triage_income_level_zero? && intake.service_preference_diy?
      route_to_diy
    elsif income_level_from_1_to_69000?(intake) || intake.triage_income_level_69001_to_89000?
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
end
